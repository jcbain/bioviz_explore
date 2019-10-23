//
// r2d3: https://rstudio.github.io/r2d3
//

var chromeCount = [1, 2];

var chromes = svg.append("g")
             .attr("class", "chromes");
             
var bases = svg.append("g")
           .attr("class", "bases")

var chromeHeight = 480;
var lineWidth = 5;

var barHeight = (((chromeHeight - (lineWidth * 2)))-0.1)  / data.length;

var yScale = d3.scaleLinear()
               .domain([0, data.length])
               .range([chromeHeight, 10]);



             
chromes.selectAll('chromes')
       .data(chromeCount)
       .enter()
       .append('rect')
       .attr('width', 50)
       .attr('height', chromeHeight)
       .attr('x', function(d){return d * 65})
       .attr('y', 10)
       .attr('rx', 10)
       .attr('ry', 10)
       .attr('fill', 'blue')
       .attr('stroke', 'pink')
       .attr('stroke-opacity', 0.9)
       .attr('fill-opacity', 0.1)
       .attr('stroke-width', lineWidth);
       
bases.selectAll('bases')
     .data(data)
     .enter()
     .append('rect')
     .attr('width', 50)
     .attr('height', barHeight)
     .attr('x', 65)
     .attr('y', function(d, i){return yScale(i)})
     .attr('fill', 'blue')
     .attr('stroke', 'pink')
     .attr('stroke-opacity', 0.9)
     .attr('fill-opacity', 0.1)
      .attr('stroke-width', .5);