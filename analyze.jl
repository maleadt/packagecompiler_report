using DataFrames, Serialization, PkgEval

function main()
    cd(@__DIR__) do
        isdir("logs") && rm("logs"; recursive=true)
        isfile("REPORT.md") && rm("REPORT.md")

        if !isfile("df.jls") && isfile("df.jls.xz")
            run(`xz --keep --decompress df.jls.xz`)
        end

        @assert isfile("df.jls")
        df = deserialize("df.jls")
        julia_version = only(unique(map(config->config.julia, df.config)))
        packages = unique(df.name)
        filter!(packages) do package
            !endswith(package, "_jll")
        end

        # write logs and classify
        println("Writing logs")
        mkdir("logs")
        ok = []
        failed_regular = []
        failed_compiled = []
        uncompilable = []
        for package in packages
            results = df[df.name .== package, :]

            regular = results[results.config .== Configuration(julia_version, false), :]
            compiled = results[results.config .== Configuration(julia_version, true), :]
            @assert size(regular,1) == 1 && size(compiled, 1) == 1
            regular = regular[1, :]
            compiled = compiled[1, :]

            regular.log !== missing && write("logs/$(package).regular.log", regular.log)
            compiled.log !== missing && write("logs/$(package).compiled.log", compiled.log)

            if compiled.status !== :ok && compiled.reason === :uncompilable
                @error "$package could not be compiled"
                push!(uncompilable, package)
            elseif regular.status !== :ok
                @warn "$package failed regular tests: $(regular.reason)"
                push!(failed_regular, package)
            elseif regular.status === :ok && compiled.status === :ok
                @info "$package passed tests in both cases"
                push!(ok, package)
            else
                @error "$package failed test when compiled: $(compiled.reason)"
                push!(failed_compiled, package)
            end
        end

        # generate report
        println("Generating report")
        open("REPORT.md", "w") do io
            println(io, "# Package evaluation with PackageCompiler\n")

            print(io, "Evaluated $(length(packages)) packages using Julia $julia_version:")
            print(io, " $(trunc(Int, 100*length(ok)/length(packages)))% are fully compatible with compilation,")
            print(io, " $(trunc(Int, 100*length(failed_regular)/length(packages)))% might be but fail some of their tests either way,")
            print(io, " $(trunc(Int, 100*length(uncompilable)/length(packages)))% could not be compiled and")
            println(io, " $(trunc(Int, 100*length(failed_compiled)/length(packages)))% actually fail their tests when compiled.\n")

            for (title, list, description) in (
                ("Package could not be compiled", uncompilable, raw"fail to compile with PackageCompiler.jl. Often, this is due to an incompatibility (e.g. `__precompile__(false)`, accessing run-time libraries like X11 during compilation, etc). In rare cases it might be caused by a bug in PackageCompiler.jl or Julia itself. Inspect the `compiled` log for more details."),
                ("Issues when compiled", failed_compiled, "do not pass their tests only when compiled. This is indicative of behavior incompatible with compilation, e.g., embedding paths to the compile-time environment, or depending on libraries outside of Julia's artifact system. Inspect the `compiled` log for more details."),
                ("Issues in regular mode", failed_regular, "do not pass their tests even when the package was not compiled. Due to this, it is difficult to know whether compilation introduces additional failures or not. Inspect the `regular` log for more details."),
                ("No issues", ok, "always pass their tests."))
                println(io, "## $(title)\n")
                println(io, "The following $(length(list)) packages $description\n")
                for package in list
                    results = df[df.name .== package, :]

                    regular = results[results.config .== Configuration(julia_version, false), :]
                    compiled = results[results.config .== Configuration(julia_version, true), :]
                    regular = regular[1, :]
                    compiled = compiled[1, :]

                    print(io, "- $(package): [regular](logs/$(package).regular.log)")
                    if regular.status !== :ok && regular.reason !== missing
                        print(io, " ($(PkgEval.reasons[regular.reason]))")
                    end
                    print(io, ", [compiled](logs/$(package).compiled.log)")
                    if compiled.status !== :ok && compiled.reason !== missing
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
