//
// r2d3: https://rstudio.github.io/r2d3
//


// Data
var chromeCount = d3.nest()
                    .key(function(d) { return d.genome; })
                    .rollup(function (v) { return v.length; })
                    .entries(data);

// console.log(JSON.stringify(data));
var chromeOneData = data.filter(function(d){return d.genome == "genome1"});
var chromeTwoData = data.filter(function(d){return d.genome == "genome2"});


var genomeLength = chromeOneData.length;
var xPosition = 65;

var chromeHeight = 580;
var chromeWidth = 50; 
var chromeStrokeWidth = .5;
var chromeRounding = 10;
var chromeYPosition = 10; 
var baseStrokeWidth = 0.2;
var baseHeight = (chromeHeight / genomeLength) - baseStrokeWidth;
var baseWidth = chromeWidth - baseStrokeWidth - chromeStrokeWidth;

console.log(baseHeight);
var yScale = d3.scaleLinear()
               .domain([genomeLength, 0])
               .range([chromeHeight - chromeRounding - (baseStrokeWidth/2), 
                       chromeYPosition + chromeRounding + (baseStrokeWidth/2)]);

// svg elements
var chromes = svg.append("g")
             .attr("class", "chromes");
             
var bases = svg.append("g")
           .attr("class", "genome1");
           
var bases = svg.append("g")
           .attr("class", "genome2");

bases.selectAll('genome1')
     .data(chromeOneData)
     .enter()
     .append('rect')
     .attr('width', baseWidth)
     .attr('height', baseHeight)
     .attr('x', xPosition + (baseStrokeWidth/2) + (chromeStrokeWidth/2))
     .attr('y', function(d, i){return yScale(i)})
     .attr('fill', function(d){
             if (d.select_coef < 0){
                     return 'pink';
             } else if (d.select_coef > 0){
                     return 'yellow';
             } else {
                     return 'white';
             }
     })
     .attr('stroke', 'black')
     .attr('stroke-opacity', 1)
     .attr('fill-opacity', 0.9)
     .attr('stroke-width', baseStrokeWidth);
     
bases.selectAll('genome2')
     .data(chromeTwoData)
     .enter()
     .append('rect')
     .attr('width', baseWidth)
     .attr('height', baseHeight)
     .attr('x', (xPosition * 2) + (baseStrokeWidth/2) + (chromeStrokeWidth/2))
     .attr('y', function(d, i){return yScale(i)})
     .attr('fill', function(d){
             if (d.select_coef < 0){
                     return 'pink';
             } else if (d.select_coef > 0){
                     return 'yellow';
             } else {
                     return 'white';
             }
     })
     .attr('stroke', 'black')
     .attr('stroke-opacity', 1)
     .attr('fill-opacity', 0.9)
     .attr('stroke-width', baseStrokeWidth);
     
  chromes.selectAll('chromes')
       .data(chromeCount)
       .enter()
       .append('rect')
       .attr('width', chromeWidth)
       .attr('height', chromeHeight)
       .attr('x', function(d, i){return (i + 1) * xPosition})
       .attr('y', chromeYPosition)
       .attr('rx', chromeRounding)
       .attr('ry', chromeRounding)
       .attr('fill', 'white')
       .attr('stroke', 'black')
       .attr('stroke-opacity', 1)
       .attr('fill-opacity', 0.1)
       .attr('stroke-width', chromeStrokeWidth);