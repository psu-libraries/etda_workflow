import $ from 'jquery';
window.jQuery = $;
import * as d3 from 'd3';


$(document).ready(() => {
    chart.initializeNetworkGraph();
});

const chart = {
  initializeNetworkGraph: function () {
    console.log('Initializing network graph...');
    // Ensure the 'network-graph' element exists in the DOM
    const networkGraphElement = document.getElementById("network-graph");
    console.log('networkGraphElement:');
    console.log(networkGraphElement);

    if (!networkGraphElement) {
      console.error('Element with ID "network-graph" not found.');
      return;
    }
    const committeeData = JSON.parse(networkGraphElement.getAttribute('data'));
    console.log(committeeData);


    const width = window.innerWidth;
    const svgHeight = Math.max(window.innerHeight, committeeData.length * 50 + 100);
    const left_indent = 20 + width / 4
    const right_indent = -20 + 2 * width / 3

    const svg = d3.select('#network-graph')
      .append('svg')
      .attr('width', width)
      .attr('height', svgHeight)
      .attr('display', 'inline-block')
      .append('g')
      .attr('transform', `translate(${left_indent}, ${50})`); // Adjust translation for the left section

    const svg2 = d3.select('#network-graph')
      .select('svg')
      .append('g')
      .attr('transform', `translate(${right_indent}, ${50})`); // Adjust translation for the right section

    const uniqueDepartments = Array.from(new Set(committeeData.map(d => d.department))).sort();
    const uniquePrograms = Array.from(new Set(committeeData.map(d => d.program))).sort();
    const departmentColorScale = d3.scaleOrdinal(d3.schemeCategory10).domain(uniqueDepartments);

    const departmentVertical = 150 // Adjust for department vertical spacing
    const departmentNodes = svg.selectAll('.department-node')
      .data(uniqueDepartments)
      .enter()
      .append('g')
      .attr('class', 'department-node')
      .attr('font-size', '20px')
      .attr('transform', (d, i) => `translate(0, ${i * departmentVertical})`);

    departmentNodes.append('text')
      .attr('class', 'department-text')
      .attr('x', 5)
      .attr('y', 5)
      .attr('text-anchor', 'end')
      .attr('alignment-baseline', 'middle')
      .attr('fill', 'black')
      .text(d => d);

    departmentNodes.append('circle')
      .attr('class', 'department-circle')
      .attr('cx', 30) // Adjust position of the circle
      .attr('r', 12)
      .attr('fill', d => departmentColorScale(d));

    const programVertical = 100 // Adjust for program vertical spacing
    const programNodes = svg2.selectAll('.program-node')
      .data(uniquePrograms)
      .enter()
      .append('g')
      .attr('class', 'program-node')
      .attr('font-size', '20px')
      .attr('transform', (d, i) => `translate(0, ${i * programVertical})`);

    programNodes.append('text')
      .attr('class', 'program-text')
      .attr('x', 20)
      .attr('y', 5)
      .attr('alignment-baseline', 'middle')
      .attr('fill', 'black')
      .text(d => d);

    programNodes.append('circle')
      .attr('class', 'program-circle')
      .attr('cx', -10) // Adjust position of the circle
      .attr('r', 12)
      .attr('fill', 'black');

    const links = svg.selectAll('.link')
      .data(committeeData)
      .enter()
      .append('line')
      .attr('class', 'link')
      .attr('x1', 30) // Adjust positions
      .attr('y1', d => uniqueDepartments.indexOf(d.department) * departmentVertical)
      .attr('x2', right_indent - left_indent - 10) // Adjust positions for the space between columns
      .attr('y2', d => uniquePrograms.indexOf(d.program) * programVertical)
      .style('stroke', d => departmentColorScale(d.department))
      .style('stroke-width', d => d.submissions/10)
      .style('stroke-opacity', 0.2);

    // Function to update the graph with filtered data
    function updateGraph(filteredData) {
      // Remove all department nodes, program nodes, and links
      svg.selectAll('.department-node, .program-node, .link').remove();
      svg2.selectAll('.department-node, .program-node, .link').remove();

      const uniqueFilteredDepartments = Array.from(new Set(filteredData.map(d => d.department))).sort();
      const uniqueFilteredPrograms = Array.from(new Set(filteredData.map(d => d.program))).sort();
      const departmentVertical = (uniqueFilteredPrograms.length / uniqueFilteredDepartments.length) * 100
      // Append new department nodes
      const departmentNodes = svg.selectAll('.department-node')
        .data(uniqueFilteredDepartments)
        .enter()
        .append('g')
        .attr('class', 'department-node')
        .attr('font-size', '20px')
        .attr('transform', (d, i) => `translate(0, ${i * departmentVertical})`);

      departmentNodes.append('text')
        .attr('class', 'department-text')
        .attr('x', 5)
        .attr('y', 5)
        .attr('text-anchor', 'end')
        .attr('alignment-baseline', 'middle')
        .attr('fill', 'black')
        .text(d => d);

      departmentNodes.append('circle')
        .attr('class', 'department-circle')
        .attr('cx', 30) // Adjust position of the circle
        .attr('r', 12)
        .attr('fill', d => departmentColorScale(d));

      // Append new program nodes
      const programNodes = svg2.selectAll('.program-node')
        .data(uniqueFilteredPrograms)
        .enter()
        .append('g')
        .attr('class', 'program-node')
        .attr('font-size', '20px')
        .attr('transform', (d, i) => `translate(0, ${i * programVertical})`);

      programNodes.append('text')
        .attr('class', 'program-text')
        .attr('x', 20)
        .attr('y', 5)
        .attr('alignment-baseline', 'middle')
        .attr('fill', 'black')
        .text(d => d);

      programNodes.append('circle')
        .attr('class', 'program-circle')
        .attr('cx', -10) // Adjust position of the circle
        .attr('r', 12)
        .attr('fill', 'black');

      const links = svg.selectAll('.link')
        .data(filteredData);

      // Append new links and update existing ones
      links.enter()
        .append('line')
        .attr('class', 'link')
        //.merge(links)
        .attr('x1', 30)
        .attr('y1', d => uniqueFilteredDepartments.indexOf(d.department) * departmentVertical)
        .attr('x2', right_indent - left_indent - 10)
        .attr('y2', d => uniqueFilteredPrograms.indexOf(d.program) * programVertical)
        .style('stroke', d => departmentColorScale(d.department))
        .style('stroke-width', d => d.submissions)
        .style('stroke-opacity', 0.3);
    }


    // Handle college selection event
    const collegeSelect = document.getElementById('college-select');

    collegeSelect.addEventListener('change', function () {
      const selectedCollege = collegeSelect.value;

      // Filter the data based on the selected college
      const filteredData = committeeData.filter(d => selectedCollege === '' || d.college === selectedCollege);
      // Update the graph with the filtered data
      updateGraph(filteredData);
    });
  }
};
