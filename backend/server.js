const express = require('express');
const app = express();
var request = require('request');
var cheerio = require('cheerio');
var Graph = require('graph-data-structure');
var bodyParser = require('body-parser');
var fs = require('fs');

var graph = Graph();

fs.readFile("coursegraph.txt",function(err, data){
    if(!err){
        var array = data.toString().split('\n')
        for(var i=0; i<array.length; i++){
            var strings = array[i].split(":")
            var course = strings[0]
            var other = strings[1].split(",")
            for(var j=0; j<other.length; j++){
                graph.addEdge(course, other[j])
            }
        }
    }
})

// Source Nodes
graph.addNode('ICS 90')
//graph.addEdge('ICS 31','ICS 32');
//graph.addEdge('ICS 31','ICS 51');
//graph.addEdge('ICS 6B','ICS 51');
//graph.addEdge('ICS 6B','ICS 6D');
//
//
//graph.addEdge('ICS 32','INF 43');
//graph.addEdge('ICS 32','ICS 33');
//graph.addEdge('ICS 33','ICS 45C');
//graph.addEdge('ICS 45C','ICS 46');
//graph.addEdge('ICS 51','ICS 53');

function sourceNodes(graph){
    var nodes = graph.nodes()
    result = []
    for(var x=0; x < nodes.length; x++){
        if(graph.indegree(nodes[x]) == 0){
            result.push(nodes[x]);
        } 
    }
    return result;
}

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

//app.get('/',function(req, res){
//    var course = req.param('course');
//    var courses = edges[course];
//    res.send(courses);
//});

app.post('/', function(req, res){
    var copyGraph = Graph(graph.serialize());
    var courses = req.body.courses;
    var result = [];
    
    for(var i=0; i<courses.length; i++){
        copyGraph.removeNode(courses[i]);
    }
    
//    for(var x=0; x < courses.length; x++ ){
//        var new_courses = []
//        if (courses[x] in edges){
//            new_courses = edges[courses[x]]
//        }
//        for(var i=0; i < new_courses.length; i++){
//            if (!courses.includes(new_courses[i])){
//                result.push(new_courses[i])
//            }
//        }
//    }
    res.status(200).send({"result": sourceNodes(copyGraph)});
})

function compare(a,b){
    if(a.course.length>b.course.length){
        return 1
    }
    if(a.course.length<b.course.length){
        return -1
    }
    else{
        if(a.course>b.course){
            return 1
        }
        else if(a.course<b.course){
            return -1
        }
    }
    return 0
}

app.get('/listings', function(req, res){
    var result = []
    if (req.param('department') == "ICS"){
        result.push({"course":"AP CS", "title":"Minimum score of 3"});
    }
    url = 'http://www.ics.uci.edu/ugrad/courses/listing.php?year=2017&level=ALL&department='+ req.param('department')+'&program=ALL';
    request(url, function(error, response , html){
        if(!error){
            var $ = cheerio.load(html);
            
            $('.name').each(function(i, element){
                var data = $(element).children().last();
                var course = data.text().trim().split(' ');
                var code = course[1];
                var finalCourse = course[0] + ' ';
                if(code.includes('0'))
                {
                    for(var j=0; j<code.length; j++){
                        if(code[j] != '0'){
                            finalCourse += code.slice(j);
                            break;
                        }
                    }
                }else{
                    finalCourse += code;
                }

                result.push({
                    "course": finalCourse,
                    "title": data.attr('title').trim()
                });
            })
        }
        result.sort(compare);
        res.status(200).send({"result": result});
    })
})

app.get('/', function(req, res){
    res.send("Welcome to UCI Courses!")
})

app.listen(process.env.PORT || 3000, function(){
    console.log("Courses API running on 3000");
})