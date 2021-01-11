using DataFrames, Serialization, PkgEval

function main()
    cd(@__DIR__) do
        isdir("logs") && rm("logs"; recursive=true)
        isfile("REPORT.md") && rm("REPORT.md")

        @assert isfile("df.jls")
        df = deserialize("df.jls")
        julia_version = only(unique(map(config->config.julia, df.config)))
        packages = unique(df.name)

        # write logs and classify
        mkdir("logs")
        ok = []
        failed_regular = []
        failed_compiled = []
        for package in packages
            results = df[df.name .== package, :]

            regular = results[results.config .== Configuration(julia_version, false), :]
            compiled = results[results.config .== Configuration(julia_version, true), :]
            @assert size(regular,1) == 1 && size(compiled, 1) == 1
            regular = regular[1, :]
            compiled = compiled[1, :]

            write("logs/$(package).regular.log", regular.log)
            write("logs/$(package).compiled.log", compiled.log)

            if regular.status != :ok
                @warn "$package failed regular tests: $(regular.reason)"
                push!(failed_regular, package)
            elseif regular.status == :ok && compiled.status == :ok
                @info "$package passed tests in both cases"
                push!(ok, package)
            else
                @error "$package failed test when compiled: $(compiled.reason)"
                push!(failed_compiled, package)
            end
        end

        # generate report
        open("REPORT.md", "w") do io
            println(io, "# Package evaluation with PackageCompiler\n")

            println(io, "Evaluated using Julia $julia_version.\n")

            for (title, list) in (("Issues when compiled", failed_compiled),
                                  ("Issues in regular mode", failed_regular),
                                  ("No issues", ok))
                println(io, "## $(title)\n")
                for package in list
                    results = df[df.name .== package, :]

                    regular = results[results.config .== Configuration(julia_version, false), :]
                    compiled = results[results.config .== Configuration(julia_version, true), :]
                    regular = regular[1, :]
                    compiled = compiled[1, :]

                    print(io, "- $(package): [regular](logs/$(package).regular.log)")
                    if regular.status !== :ok
                        print(io, " ($(PkgEval.reasons[regular.reason]))")
                    end
                    print(io, ", [compiled](logs/$(package).compiled.log)")
                    if compiled.status !== :ok
                        print(io, " ($(PkgEval.reasons[compiled.reason]))")
                    end
                    println(io)
                end
                println(io)
            end
        end

        # stage
        run(`git add REPORT.md logs`)
    end

    return
end

isinteractive() || main()
