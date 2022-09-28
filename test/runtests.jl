using FCSFiles
using FileIO
using Test, HTTP

@testset "FCSFiles test suite" begin

    # test loading an FCS 2.0 file
    @testset "Loading an FCS 2.0 file" begin
        # download the FCS 2.0 file
        cwd = pwd()
        cd(cwd*"/testdata")
        @info "Downloading FCS 2.0 file ..."
        io = open("testFCS2.fcs", "w")
        r = HTTP.request("GET", "https://github.com/eyurtsev/fcsparser/blob/master/fcsparser/tests/data/FlowCytometers/FACSCaliburHTS/Sample_Well_A02.fcs?raw=true", response_stream=io)
        close(io)
        cd(cwd)
        @info "Done."

        # load the FCS 2.0 file
        @test_throws CapturedException @test_warn "FSC2.0 files are not guaranteed to work" flowrun = load("testdata/testFCS2.fcs")

        # cleanup
        rm("testdata/testFCS2.fcs", force=true)
        @info "FCS 2.0 file removed"
    end

    # test the size of the file
    @testset "SSC-A size" begin
        flowrun = load("testdata/BD-FACS-Aria-II.fcs")

        @test length(flowrun["SSC-A"]) == 100000
    end

    # test the loading of a large FCS file
    @testset "Loading of large FCS file" begin
        # download the large FCS file
        cwd = pwd()
        cd(cwd*"/testdata")
        @info "Downloading large FCS file ..."
        io = open("testLargeFile.fcs", "w")
        r = HTTP.request("GET", "https://flowrepository.org/experiments/1177/fcs_files/113151/download", response_stream=io)
        close(io)
        cd(cwd)
        @info "Done."

        # load the large file
        flowrun = load("testdata/testLargeFile.fcs")
        @test length(flowrun.data) == 50
        @test length(flowrun.params) == 268

        # cleanup
        rm("testdata/testLargeFile.fcs", force=true)
        @info "Large file removed"
    end

    @testset "Loading float-encoded file" begin
        flowrun = load("testdata/Attune.fcs")

        @test length(flowrun["SSC-A"]) == 10000
        @test flowrun["FSC-A"][2] == 12849.0f0
    end

    @testset "Loading Accuri file" begin
        flowrun = load("testdata/BD_Accuri_C6.fcs")
        @test length(flowrun["SSC-A"]) == 40000
        @test flowrun["SSC-A"][2] == 911

    end
end
