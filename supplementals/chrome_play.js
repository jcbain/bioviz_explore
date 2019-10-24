//
// r2d3: https://rstudio.github.io/r2d3
//


// Data
var chromeCount = d3.nest()
                    .key(function(d) { return d.genome; })
                    .rollup(function (v) { return v.length; })
                    .entries(data);
// console.log(JSON.stringify(chromeCount))

var xPosition = 65;

var chromeHeight = 580;
var chromeWidth = 200; 
var chromeStrokeWidth = 2;
var chromeRounding = 10;
var chromeYPosition = 10; 
var baseStrokeWidth = 5;
var baseHeight = (chromeHeight / data.length) - (2 * baseStrokeWidth);
var baseWidth = chromeWidth - baseStrokeWidth - chromeStrokeWidth;

console.log(baseHeight);
var yScale = d3.scaleLinear()
               .domain([data.length, 0])
               .range([chromeHeight - (chromeRounding), chromeYPosition + (chromeRounding)]);

// svg elements
var chromes = svg.append("g")
             .attr("class", "chromes");
             
var bases = svg.append("g")
           .attr("class", "genome1");

             
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
       .attr('stroke-opacity', 0.9)
       .attr('fill-opacity', 0.1)
       .attr('stroke-width', chromeStrokeWidth);
       
bases.selectAll('genome1')
     .data(data)
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
                     return '#d9d9d9';
             }
     })
     .attr('stroke', function(d){
             if (d.select_coef < 0){
                     return 'pink';
             } else if (d.select_coef > 0){
                     return 'yellow';
             } else {
                     return '#a3a3a3';
             }
     })
     .attr('stroke-opacity', 0.9)
     .attr('fill-opacity', 0.9)
     .attr('stroke-width', baseStrokeWidth);