# Package evaluation with PackageCompiler

Evaluated using Julia 1.5.3-599f52c4c6.

## Issues when compiled

- DataDrivenDiffEq: [regular](logs/DataDrivenDiffEq.regular.log), [compiled](logs/DataDrivenDiffEq.compiled.log) (there were unidentified errors)

## Issues in regular mode

- DiffEqGPU: [regular](logs/DiffEqGPU.regular.log) (package could not be installed), [compiled](logs/DiffEqGPU.compiled.log) (package could not be installed)
- ValidatedNumerics: [regular](logs/ValidatedNumerics.regular.log) (package has test failures), [compiled](logs/ValidatedNumerics.compiled.log) (package has test failures)
- DualNumbers: [regular](logs/DualNumbers.regular.log) (package has test failures), [compiled](logs/DualNumbers.compiled.log) (package has test failures)
- Surrogates: [regular](logs/Surrogates.regular.log) (package has test failures), [compiled](logs/Surrogates.compiled.log) (there were unidentified errors)
- DiffEqUncertainty: [regular](logs/DiffEqUncertainty.regular.log) (package could not be installed), [compiled](logs/DiffEqUncertainty.compiled.log) (package could not be installed)
- DiffEqFlux: [regular](logs/DiffEqFlux.regular.log) (package could not be installed), [compiled](logs/DiffEqFlux.compiled.log) (there were unidentified errors)

## No issues

- TaylorSeries: [regular](logs/TaylorSeries.regular.log), [compiled](logs/TaylorSeries.compiled.log)
- LinearMaps: [regular](logs/LinearMaps.regular.log), [compiled](logs/LinearMaps.compiled.log)
- Zygote: [regular](logs/Zygote.regular.log), [compiled](logs/Zygote.compiled.log)
- StaticArrays: [regular](logs/StaticArrays.regular.log), [compiled](logs/StaticArrays.compiled.log)
- DifferentialEquations: [regular](logs/DifferentialEquations.regular.log), [compiled](logs/DifferentialEquations.compiled.log)
- IterativeSolvers: [regular](logs/IterativeSolvers.regular.log), [compiled](logs/IterativeSolvers.compiled.log)
- ForwardDiff: [regular](logs/ForwardDiff.regular.log), [compiled](logs/ForwardDiff.compiled.log)
- Distributions: [regular](logs/Distributions.regular.log), [compiled](logs/Distributions.compiled.log)
- ZMQ: [regular](logs/ZMQ.regular.log), [compiled](logs/ZMQ.compiled.log)
- Optim: [regular](logs/Optim.regular.log), [compiled](logs/Optim.compiled.log)
- Unitful: [regular](logs/Unitful.regular.log), [compiled](logs/Unitful.compiled.log)
- ModelingToolkit: [regular](logs/ModelingToolkit.regular.log), [compiled](logs/ModelingToolkit.compiled.log)

