using FCSFiles
using FileIO
using Test

project_root = isfile("runtests.jl") ? abspath("..") : abspath(".")
testdata_dir = joinpath(project_root, "test", "fcsexamples")
if !isdir(testdata_dir)
    run(`git -C $(joinpath(project_root, "test")) clone https://github.com/tlnagy/fcsexamples.git --branch main --depth 1`)
else
    run(`git -C $testdata_dir fetch`)
    # for reproducibility we should use hard reset
    run(`git -C $testdata_dir reset --hard origin/main`)
    run(`git -C $testdata_dir pull`)
end

@testset "FCSFiles test suite" begin
    # test the size of the file
    @testset "SSC-A size" begin
	flowrun = load(joinpath(testdata_dir, "BD-FACS-Aria-II.fcs"))
        @test length(flowrun["SSC-A"]) == 100000
    end

    # test the loading of a large FCS file
    @testset "Loading of large FCS file" begin
        # load the large file
	flowrun = load(joinpath(testdata_dir, "Day 3.fcs"))
        @test length(flowrun.data) == 50
        @test length(flowrun.params) == 268
    end

    @testset "Loading float-encoded file" begin
        flowrun = load(joinpath(testdata_dir, "Applied Biosystems - Attune.fcs"))

        @test length(flowrun["SSC-A"]) == 22188
        @test flowrun["FSC-A"][2] == 244982.11f0
    end

    @testset "Loading Accuri file" begin
        flowrun = load(joinpath(testdata_dir, "Accuri - C6.fcs"))
        @test length(flowrun["SSC-A"]) == 63273
        @test flowrun["SSC-A"][2] == 370971

    end
end
