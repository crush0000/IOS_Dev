var fruits=["alma","almurt","banan","qulpynai","qauyn"]
print(fruits[2])

var Numbers: Set<Int> = [1,2,3,4]
Numbers.insert(25)
print(Numbers)

var languages = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print(languages["Swift"] ?? 0)


var colors = ["qara","aq","jasyl","sary"]
 colors[1] = "kok"
 print(colors)


let set1: Set<Int> = [1,2,3,4]
let set2: Set<Int> = [3,4,5,6]

let commonNumbers = set1.intersection(set2)
print(commonNumbers.sorted())



var scores = [
    "Aldiyar": 90,
    "Arman": 85,
    "Dias": 95
]

scores["Arman"] = 100
print(scores)


let array1 = ["apple", "banana"]
let array2 = ["cherry", "date"]

let mergedArray = array1 + array2
print(mergedArray)


var populations = [
    "Kazakhstan": 20000000,
    "USA": 340000000,
    "Japan": 123000000
]

populations["Canada"] = 40000000
print(populations)


let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]

let unionSet = animals1.union(animals2)
let finalSet = unionSet.subtracting(animals2)

print(unionSet.sorted())
print(finalSet.sorted())


let studentGrades: [String: [Int]] = [
    "Aldiyar": [90, 85, 95],
    "Arman": [80, 88, 92],
    "Dias": [75, 90, 85]
]

let secondGrade = studentGrades["Aldiyar"]?[1]
print(secondGrade ?? 0)
