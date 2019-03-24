# Day 1 Complete!
function startChanges(startingFreq::Int=0)
    currentFreq = startingFreq
    function changeFreq(change::Int)
        currentFreq += change
    end
    return changeFreq
end

function extractChanges(changes::AbstractString)
    [parse(Int, x) for x in split(changes)]
end

function getFinalState(changes)
    changeFreq = startChanges()
    for change in changes
        changeFreq(change)
    end
    return changeFreq(0)
end

function test1()
    changes = extractChanges("1 -2 3 1")
    @assert getFinalState(changes) == 3
    changes = extractChanges("1 1 1")
    @assert getFinalState(changes) == 3
    changes = extractChanges("1 1 -2")
    @assert getFinalState(changes) == 0
    changes = extractChanges("-1 -2 -3")
    @assert getFinalState(changes) == -6
    println("Success!")
end

test1()

function getInput(filename::String)
    inp = open(filename) do file
        read(file, String)
    end
    return strip(inp)
end

inp = getInput("inpP1.txt")

changes = extractChanges(inp)

function puzzle1()
    println(getFinalState(changes))
    # or
    println(sum(changes))
end

puzzle1()

# 1a - Second part of day 1

function startChangesDup(startingFreq::Int=0)
    currentFreq = startingFreq
    allFreqs = Set{Int}([currentFreq])
    function changeFreq(change::Int)
        currentFreq += change
        if currentFreq in allFreqs
            return currentFreq, true
        else
            push!(allFreqs, currentFreq)
            return currentFreq, false
        end
    end
    return changeFreq
end

function getFinalStateDup(changes)
    changeFreq = startChangesDup()
    gotDup = false
    while !gotDup
        for change in changes
            freq, gotDup = changeFreq(change)
            if gotDup
                return freq
            end
        end
    end
    return changeFreq(0)
end

function test1a()
    changes = extractChanges("1 -2 3 1")
    @assert getFinalStateDup(changes) == 2
    changes = extractChanges("1 -1")
    @assert getFinalStateDup(changes) == 0
    changes = extractChanges("3 3 4 -2 -4")
    @assert getFinalStateDup(changes) == 10
    changes = extractChanges("-6 3 8 5 -6")
    @assert getFinalStateDup(changes) == 5
    changes = extractChanges("7 7 -2 -7 -4")
    @assert getFinalStateDup(changes) == 14
    println("Success!")
end

test1a()

function puzzle1a()
    println(getFinalStateDup(changes))
end

puzzle1a()

# Day 2 - Completed!

function getCounts(aStr::AbstractString)
    uni = unique(aStr)
    cnts = [count(x -> x==y, aStr) for y in uni]
    gotTwo =   any([x == 2 for x in cnts])
    gotThree = any([x == 3 for x in cnts])
    return gotTwo, gotThree
end

function getChecksum(inp)
    strs = split(inp)
    cntTwo, cntThree = 0, 0
    for aStr in strs
        gotTwo, gotThree = getCounts(aStr)
        if gotTwo
            cntTwo += 1
        end
        if gotThree
            cntThree += 1
        end
    end
    cntTwo*cntThree
end

function test2()
    inp = """abcdef
    bababc
    abbcde
    abcccd
    aabcdd
    abcdee
    ababab"""
    @assert getChecksum(inp) == 12
    println("Success!")
end

test2()

inp = getInput("inpP2.txt")

function puzzle2()
    println(getChecksum(inp))
end

puzzle2()

# 2a

function getDiff(str1::AbstractString, str2::AbstractString)
    @assert length(str1) == length(str2)
    nums1 = [Int(x) for x in str1]
    nums2 = [Int(x) for x in str2]
    df = nums2 - nums1
end

function gotDiffOfOne(str1::AbstractString, str2::AbstractString)
    @assert length(str1) == length(str2)
    df = getDiff(str1, str2)
    if count(x -> x==0, df) == length(df)-1
        return true
    else
        return false
    end
end

function testGotDiff()
    @assert gotDiffOfOne("fghij", "fguij")
    @assert !gotDiffOfOne("fghij", "fguiq")
    @assert !gotDiffOfOne("fghij", "fguif")
    println("Success!")
end

testGotDiff()

function findDiffOfOne(inp)
    strs = split(inp)
    rng = 1:length(strs)
    for (ix, aStr) in enumerate(strs)
        for ixCmp in rng
            if ixCmp != ix
                if gotDiffOfOne(aStr, strs[ixCmp])
                    return aStr, strs[ixCmp]
                end
            end
        end
    end
end

function findIxOfDiff(str1::AbstractString, str2::AbstractString)
    df = getDiff(str1, str2)
    findfirst(x -> x != 0, df)
end

function getSubString(str::AbstractString, ix)
    string(str[1:ix-1], str[ix+1:end])
end

function doItAll2a(inp)
    str1, str2 = findDiffOfOne(inp)
    ix = findIxOfDiff(str1, str2)
    getSubString(str1, ix)
end

function test2a()
    @assert doItAll2a("fghij fguij") == "fgij"
    println("Success!")
end

test2a()

function puzzle2a()
    println(doItAll2a(inp))
end

puzzle2a()

# Day 3 - Complete!

function parseLine(line)
    fields = split(line)
    id = parse(Int, fields[1][2:end])
    pos = fields[3]
    poses = split(pos, ',')
    x = parse(Int, poses[1])
    y = parse(Int, poses[2][1:end-1])
    size = fields[end]
    sizes = split(size, 'x')
    width = parse(Int, sizes[1])
    height = parse(Int, sizes[2])
    return id, x, y, width, height
end

function testParse()
    @assert parseLine("#1 @ 1,3: 4x4") == (1, 1, 3, 4, 4)
    @assert parseLine("#2 @ 3,1: 4x4") == (2, 3, 1, 4, 4)
    @assert parseLine("#3 @ 5,5: 2x2") == (3, 5, 5, 2, 2)
    println("Success!")
end

testParse()

function getAllLines(filename)
    allData = []
    inp = open(filename) do file
        for line in eachline(file)
            push!(allData, parseLine(line))
        end
    end
    return allData
end

function findUpperLim(allData)
    maxX = 0
    maxY = 0
    for tup in allData
        x = 1 + tup[2] + tup[4]
        if x > maxX
            maxX = x
        end
        y = 1 + tup[3] + tup[5]
        if y > maxY
            maxY = y
        end
    end
    return maxX, maxY
end

function testUpper()
    allData = getAllLines("tmpData.txt")
    @assert findUpperLim(allData) == (8, 8)
    println("Success!")
end

testUpper()

function createMatrix(allData)
    maxX, maxY = findUpperLim(allData)
    mat = zeros(Int, maxX, maxY)
    for tup in allData
        id, x, y, width, height = tup
        if all(mat[1+x:x+width, 1+y:y+height] .== 0)
            mat[1+x:x+width, 1+y:y+height] = id*ones(Int, width, height)
        else
            ixs = findall(z -> z>0, mat[1+x:x+width, 1+y:y+height])
            for ix in ixs
                ixX, ixY = ix[1]+x, ix[2]+y
                mat[ixX, ixY] = -1
            end
            ixs = findall(z -> z==0, mat[1+x:x+width, 1+y:y+height])
            for ix in ixs
                ixX, ixY = ix[1]+x, ix[2]+y
                mat[ixX, ixY] = id
            end
        end
    end
    return mat
end

function findOverlap(mat)
    ixs = findall(x -> x==-1, mat)
    length(ixs)
end

function testOverlap()
    allData = getAllLines("tmpData.txt")
    mat = createMatrix(allData)
    @assert findOverlap(mat) == 4
    println("Success!")
end

testOverlap()

function puzzle3()
    allData = getAllLines("inpP3.txt")
    mat = createMatrix(allData)
    println(findOverlap(mat))
end

puzzle3()

function findNonOverlap(mat, allData)
    ids = [x[1] for x in allData]
    areas = [x[4]*x[5] for x in allData]
    for (id, area) in zip(ids, areas)
        if sum(mat .== id) == area
            return id
        end
    end
end

function testNonOverlap()
    allData = getAllLines("tmpData.txt")
    mat = createMatrix(allData)
    @assert findNonOverlap(mat, allData) == 3
    println("Success!")
end

testNonOverlap()

function puzzle3a()
    allData = getAllLines("inpP3.txt")
    mat = createMatrix(allData)
    println(findNonOverlap(mat, allData))
end

puzzle3a()

# Day 4

using Dates

function parseLog(txt)
    lines = split(txt, "\n")
    lines = [strip(x) for x in lines if strip(x) != ""]
    pat = r"\[([^\]]+)\]"
    timeTxts = [match(pat, x)[1] for x in lines]
    pat = r"\]\s+(.+)"
    logEvents = [match(pat, x)[1] for x in lines]
    times = []
    for timeTxt in timeTxts
        dt, t = split(timeTxt)
        y, m, d = [parse(Int, x) for x in split(dt, "-")]
        h, min = [parse(Int, x) for x in split(t, ":")]
        push!(times, DateTime(y, m, d, h, min))
    end
    p = sortperm(times)
    return times[p], logEvents[p]
end

times, logEvents = parseLog("""[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up""")

function testParseLog()
    @assert logEvents[1]   == "Guard #10 begins shift"
    @assert logEvents[end] == "wakes up"
    println("Success!")
end

testParseLog()

function getUniqueGuards(logEvents)
    pat = r"#(\d+)"
    ms = [match(pat, x) for x in logEvents]
    guards = unique([parse(Int, m[1]) for m in ms if m != nothing])
end

function testGetUnique()
    @assert getUniqueGuards(logEvents) == [10, 99]
    println("Success!")
end

testGetUnique()

function findSleepTimes(times, logEvents)
    uniqueGuards = getUniqueGuards(logEvents)
    sleepTimes = Dict(zip(uniqueGuards, zeros(size(uniqueGuards))))
    freqs = Dict(zip(uniqueGuards,
                     [Dict(zip(collect(0:59), zeros(size(0:59)))) for _ in 1:length(uniqueGuards)]))
    pat = r"\d+"
    startTime = times[1]
    endTime = times[1]
    currentGuard = uniqueGuards[1]
    for (time, event) in zip(times, logEvents)
        if occursin(pat, event)
            currentGuard = parse(Int, match(pat, event).match)
        end
        if event == "falls asleep"
            startTime = time
        end
        if event == "wakes up"
            endTime = time
            sleepTimes[currentGuard] += Dates.value(convert(Dates.Minute, endTime - startTime))
            for min in Dates.value(Dates.Minute(startTime)):Dates.value(Dates.Minute(endTime))
                freqs[currentGuard][min] += 1
            end
        end
    end
    return sleepTimes, freqs
end

function testFindSleepTimes()
    sleepTimes, freqs = findSleepTimes(times, logEvents)
    @assert sleepTimes[10] == 50
    @assert freqs[10][24] == 2
    println("Success!")
end

testFindSleepTimes()

function max(x::Dict{Int64,Float64})
    curMax = min(collect(values(x))...)
    ret = 0
    for (key, val) in zip(keys(x), values(x))
        if val > curMax
            curMax = val
            ret = key
        end
    end
    return ret, curMax
end

inp = getInput("inpP4.txt")
times, logEvents = parseLog(inp)
sleepTimes, freqs = findSleepTimes(times, logEvents)

function puzzle4()
    highest, _  = max(sleepTimes)
    mostFreq, _ = max(freqs[highest])
    mostFreq -= 1
    println(highest*mostFreq)
end

puzzle4()

function puzzle4a()
    uniqueGuards = getUniqueGuards(logEvents)
    mostFreqs = [max(freqs[x]) for x in uniqueGuards]
    mostFreqIx = argmax([x[2] for x in mostFreqs])
    println(uniqueGuards[mostFreqIx]*mostFreqs[mostFreqIx][1])
end

puzzle4a()

# Day 5

function pairs(aStr::AbstractString)
    [aStr[i:i+1] for i in 1:length(aStr)-1], collect(1:length(aStr)-1)
end

function testPairs()
    @assert pairs("aAbB") == (["aA", "Ab", "bB"], [1, 2, 3])
    println("Success!")
end

testPairs()

isReactive(pair::AbstractString) = abs(Int(pair[1]) - Int(pair[2])) == 32

function testIsReactive()
    @assert isReactive("aA")
    @assert isReactive("Aa")
    @assert isReactive("zZ")
    @assert !isReactive("ab")
    @assert !isReactive("aB")
    println("Success!")
end

testIsReactive()

function reduceExp(exp::AbstractString)
    ret = exp
    ix = 1
    while true
        if isReactive(ret[ix:ix+1])
            if ix == 1
                ret = ret[3:end]
            elseif ix >= length(ret) - 1
                ret = ret[1:ix-1]
                break
            else
                ret = string(ret[1:ix-1], ret[ix+2:end])
                ix -= 1
                if ix < 1
                    ix = 1
                end
            end
        else
            ix += 1
        end
        if ix >= length(ret)
            break
        end
    end
    ret
end

function testReduceExp()
    @assert reduceExp("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
    println("Success!")
end

testReduceExp()

inp = getInput("input")

function puzzle5()
    println(length(reduceExp(inp)))
end

#puzzle5()

# 5a

function removeAndReact(exp::AbstractString)
    uniLetters = unique(lowercase(exp))
    lens = []
    for letter in uniLetters
        ixLower = findall(isequal(letter), exp)
        ixUpper = findall(isequal(uppercase(letter)), exp)
        lowestNumIx = argmin([length(ixLower), length(ixUpper)])
        if lowestNumIx == 1
            removed = exp[[x for x in 1:length(exp) if !(x in ixLower)]]
            ixOther = findall(isequal(uppercase(letter)), removed)
            removed = removed[[x for x in 1:length(removed) if !(x in ixOther)]]
        else
            removed = exp[[x for x in 1:length(exp) if !(x in ixUpper)]]
            ixOther = findall(isequal(letter), removed)
            removed = removed[[x for x in 1:length(removed) if !(x in ixOther)]]
        end
        reacted = reduceExp(removed)
        push!(lens, length(reacted))
    end
    lens
end

function testRemoveAndReact()
    removeAndReact("dabAcCaCBAcCcaDA") == [6, 6, 8, 4]
    println("Success!")
end

testRemoveAndReact()

function puzzle5a()
    println(min(removeAndReact(inp)...))
end

#puzzle5a()

# Day 6

manhatDist(p1, p2) = abs(p1[2]-p2[2]) + abs(p1[1]-p2[1])

function testDist()
    @assert manhatDist([1, 1], [1, 6]) == 5
    @assert manhatDist([1, 6], [1, 5]) == 1
    println("Success!")
end

testDist()

function initialzeMatrix(inp)
    lines = split(inp, "\n")
    coords = [split(x, ", ") for x in lines]
    xs = [parse(Int, z[1])+1 for z in coords]
    ys = [parse(Int, z[2])+1 for z in coords]
    maxX, maxY = Base.max(xs...), Base.max(ys...)
    mat = zeros(maxX, maxY)
    for (ix, (x, y)) in enumerate(zip(xs, ys))
        mat[x, y] = ix
    end
    return mat, xs, ys
end

function printMat(mat)
    cols, rows = size(mat)
    for r in 1:rows
        rowTxt = ""
        for c in 1:cols
            if mat[c, r] == 0
                rowTxt = string(rowTxt, ".")
            else
                rowTxt = string(rowTxt, Char(mat[c, r]+64))
            end
        end
        println(rowTxt)
    end
end

function testInit()
    inp = """1, 1
1, 6
8, 3
3, 4
5, 5
8, 9"""
    mat, xs, ys = initialzeMatrix(inp)
    printMat(mat)
end

testInit()

function populateMat(mat, xs, ys)
    coords = zip(xs, ys)
    cols, rows = size(mat)
    for r in 1:rows
        for c in 1:cols
            if mat[c, r] == 0
                dists = [manhatDist((c, r), coord) for coord in coords]
                if sum(dists .== min(dists...)) > 1
                    ix = 0
                else
                    ix = argmin(dists)
                end
                mat[c, r] = ix
            end
        end
    end
    mat
end

function testPopulateMat()
    inp = """1, 1
1, 6
8, 3
3, 4
5, 5
8, 9"""
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat(mat, xs, ys)
    printMat(mat)
end

testPopulateMat()

function getInternalCoords(mat, xs)
    internalCoords = []
    for ix in 1:length(xs)
        if (!(ix in mat[:, 1]) && !(ix in mat[:, end]) &&
            !(ix in mat[1, :]) && !(ix in mat[end, :]))
            push!(internalCoords, ix)
        end
    end
    internalCoords
end

function testGetInternal()
    inp = """1, 1
1, 6
8, 3
3, 4
5, 5
8, 9"""
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat(mat, xs, ys)
    @assert getInternalCoords(mat, xs) == [4, 5]
    println("Success!")
end

testGetInternal()

function getLargestArea(mat, internalCoords)
    areas = [sum(mat .== ix) for ix in internalCoords]
    Base.max(areas...)
end

function testGetLargestArea()
    inp = """1, 1
1, 6
8, 3
3, 4
5, 5
8, 9"""
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat(mat, xs, ys)
    internalCoords = getInternalCoords(mat, xs)
    @assert getLargestArea(mat, internalCoords) == 17
    println("Success!")
end

testGetLargestArea()

function puzzle6()
    inp = getInput("inpP6.txt")
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat(mat, xs, ys)
    internalCoords = getInternalCoords(mat, xs)
    println(getLargestArea(mat, internalCoords))
end

puzzle6()

function populateMat6a(mat, xs, ys, maxDist=10000)
    coords = zip(xs, ys)
    cols, rows = size(mat)
    for r in 1:rows
        for c in 1:cols
            dists = [manhatDist((c, r), coord) for coord in coords]
            if sum(dists) < maxDist
                mat[c, r] = -1
            end
        end
    end
    mat
end

function getAreaRegion(mat)
    sum(mat .== -1)
end

function testGetAregion()
    inp = """1, 1
1, 6
8, 3
3, 4
5, 5
8, 9"""
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat6a(mat, xs, ys, 32)
    @assert getAreaRegion(mat) == 16
    println("Success!")
end

testGetAregion()

function puzzle6a()
    inp = getInput("inpP6.txt")
    mat, xs, ys = initialzeMatrix(inp)
    mat = populateMat6a(mat, xs, ys)
    println(getAreaRegion(mat))
end

puzzle6a()

mutable struct Node
    nextNodes::Set{Node}
    prevNodes::Set{Node}
    index::Int
end

mutable struct Graph
    nodes::Set{Node}
end

function hasnode(graph::Graph, index::Int)
    for node in graph.nodes
        if node.index == index; return true; end
    end
    false
end

function getnode(graph::Graph, index::Int)
    for node in graph.nodes
        if node.index == index; return node; end
    end
end

function setnodeprev!(graph::Graph, indexTo::Int, indexFrom::Int)
    for node in graph.nodes
        if node.index == indexTo
            push!(node.prevNodes, getnode(graph, indexFrom))
            break
        end
    end
end

function setnodenext!(graph::Graph, indexFrom::Int, indexTo::Int)
    for node in graph.nodes
        if node.index == indexFrom
            push!(node.nextNodes, getnode(graph, indexTo))
            break
        end
    end
end

function addnode!(graph::Graph, index::Int)
    if !hasnode(graph, index)
        push!(graph.nodes, Node(Set(), Set(), index))
    else
        println("Node already exists.")
    end
end

function addedge!(graph::Graph, indexFrom::Int, indexTo::Int)
    if !hasnode(graph, indexFrom); addnode!(graph, indexFrom); end
    if !hasnode(graph, indexTo); addnode!(graph, indexTo); end
    setnodenext!(graph, indexFrom, indexTo)
    setnodeprev!(graph, indexTo, indexFrom)
end

function testGraph()
    graph = Graph(Set())
    addedge!(graph, 1, 2)
    node = getnode(graph, 1)
    @assert node.index == 1
    nodeNext = first(node.nextNodes)
    @assert nodeNext.index == 2
    node = getnode(graph, 2)
    nodePrev = first(node.prevNodes)
    @assert nodePrev.index == 1
    println("Success!")
end

testGraph()
