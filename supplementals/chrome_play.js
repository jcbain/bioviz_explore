//
// r2d3: https://rstudio.github.io/r2d3
//
//console = d3.window(svg.node()).console;

// Data
var chromeCount = d3.nest()
                    .key(function(d) { return d.genome; })
                    .rollup(function (v) { return v.length; })
                    .entries(data);

// console.log(JSON.stringify(data));
var chromeOneData = data.filter(function(d){return d.genome == "genome1"});
var chromeTwoData = data.filter(function(d){return d.genome == "genome2"});

// colors
var positiveColor     = '#ebc634';
var negativeColor     = '#ffb3ed';
var wildTypeColor     = '#f7f7f7';
var baseStrokeColor   = '#ffffff';
var chromeStrokeColor = '#000000';

var minAbsoluteEffect = 0;
var maxAbsoluteEffect = d3.max(data, function(d){ return Math.abs( d.select_coef );});
// console.log(JSON.stringify(maxAbsoluteEffect));

var genomeLength = chromeOneData.length;
var xPosition = 65;

var chromeHeight = 580;
var chromeWidth = 50; 
var chromeStrokeWidth = 0.5;
var chromeRounding = 20;
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
                     return positiveColor;
             } else if (d.select_coef > 0){
                     return negativeColor;
             } else {
                     return wildTypeColor;
             }
     })
     .attr('stroke', baseStrokeColor)
     .attr('stroke-opacity', 1)
     .attr('fill-opacity', function(d){
             if (d.select_coef === 0){
                     return 1;
             } else {
                     return (Math.abs(d.select_coef) - minAbsoluteEffect)/ (maxAbsoluteEffect - minAbsoluteEffect);
             }
     })
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
                     return positiveColor;
             } else if (d.select_coef > 0){
                     return negativeColor;
             } else {
                     return wildTypeColor;
             }
     })
     .attr('stroke', baseStrokeColor)
     .attr('stroke-opacity', 1)
     .attr('fill-opacity', function(d){
             if (d.select_coef === 0){
                     return 1;
             } else {
                     return (Math.abs(d.select_coef) - minAbsoluteEffect)/ (maxAbsoluteEffect - minAbsoluteEffect);
             }
     })
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
       .attr('fill', wildTypeColor)
       .attr('stroke', chromeStrokeColor)
       .attr('stroke-opacity', 1)
       .attr('fill-opacity', 1)
       .attr('stroke-width', chromeStrokeWidth);
       