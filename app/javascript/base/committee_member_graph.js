import $ from 'jquery';
window.jQuery = $;
import * as d3 from 'd3';

class NetworkGraph {
  constructor() {
    this.departmentSVG = null;
    this.programSVG = null;
    this.committeeData = [];
    this.uniqueDepartments = [];
    this.uniquePrograms = [];
    this.departmentColorScale = null;
  }

  // Load committee data from the DOM
  loadCommitteeData() {
    const networkGraphElement = document.getElementById('network-graph');

    if (!networkGraphElement) {
      console.error('Element with ID "network-graph" not found.');
      return;
    }

    this.committeeData = JSON.parse(networkGraphElement.getAttribute('data'));
  }

  // Create the main SVG elements
  createSVG() {
    const width = window.innerWidth;
    const svgHeight = Math.max(window.innerHeight, this.committeeData.length * 50 + 100);
    const leftIndent = 20 + width / 4;
    const rightIndent = -20 + 2 * width / 3;

    this.departmentSVG = d3.select(`#network-graph`)
    .append('svg')
    .attr('width', width)
    .attr('height', svgHeight)
    .attr('display', 'inline-block')
    .append('g')
    .attr('transform', `translate(${leftIndent}, ${50})`); // Adjust translation for the left section

    this.programSVG = d3.select('#network-graph')
    .select('svg')
    .append('g')
    .attr('transform', `translate(${rightIndent}, ${50})`); // Adjust translation for the right section

    // Call these functions here
    this.createDepartmentNodes();
    this.createProgramNodes();
    this.createLinks();
  }

  // Extract unique departments and programs, and set up color scale
  createUniqueDepartmentsAndPrograms(data = this.committeeData) {
    this.uniqueDepartments = Array.from(new Set(data.map(d => d.department))).sort();
    this.uniquePrograms = Array.from(new Set(data.map(d => d.program))).sort();
    console.log(this.uniquePrograms)
    this.departmentColorScale = d3.scaleOrdinal(d3.schemeCategory10).domain(this.uniqueDepartments);
  }

  // Create department nodes
  createDepartmentNodes(data = this.uniqueDepartments, departmentVertical = 150) {
    const departmentNodes = this.departmentSVG.selectAll('.department-node')
      .data(data)
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
      .attr('cx', 30)
      .attr('r', 12)
      .attr('fill', d => this.departmentColorScale(d));
  }

  // Create program nodes
  createProgramNodes(data = this.uniquePrograms) {
    const programVertical = 100;

    const programNodes = this.programSVG.selectAll('.program-node')
        .data(data)
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
        .attr('cx', -10)
        .attr('r', 12)
        .attr('fill', 'black');
    console.log(programNodes)
  }


  // Create links between department and program nodes
  createLinks() {
    const departmentVertical = 150;
    const programVertical = 100;
    const width = window.innerWidth;
    const leftIndent = 20 + width / 4;
    const rightIndent = -20 + 2 * width / 3;

    const links = this.departmentSVG.selectAll('.link')
      .data(this.committeeData)
      .enter()
      .append('line')
      .attr('class', 'link')
      .attr('x1', 30)
      .attr('y1', d => this.uniqueDepartments.indexOf(d.department) * departmentVertical)
      .attr('x2', rightIndent - leftIndent - 10)
      .attr('y2', d => this.uniquePrograms.indexOf(d.program) * programVertical)
      .style('stroke', d => this.departmentColorScale(d.department))
      .style('stroke-width', d => Math.max(d.submissions / 25, 1))
      .style('stroke-opacity', 0.2);
  }

  // Update the graph with filtered data
  updateGraph(filteredData) {
    // Recalculate unique departments and programs based on filtered data
    this.createUniqueDepartmentsAndPrograms(filteredData);

    // Calculate department and program vertical spacing based on the filtered data length
    const departmentVertical = (this.uniquePrograms.length / this.uniqueDepartments.length) * 100;

    // Remove existing department and program nodes
    this.departmentSVG.selectAll('.department-node').remove();
    this.programSVG.selectAll('.program-node').remove();

    // Recreate department and program nodes with filtered data
    this.createDepartmentNodes(this.uniqueDepartments, departmentVertical);
    this.createProgramNodes(this.uniquePrograms);

    // Remove existing links
    this.departmentSVG.selectAll('.link').remove();

    // Recreate links with the updated data
    const programVertical = 100;
    const width = window.innerWidth;
    const leftIndent = 20 + width / 4;
    const rightIndent = -20 + 2 * width / 3;

    const links = this.departmentSVG.selectAll('.link')
      .data(filteredData);

    links.enter()
      .append('line')
      .attr('class', 'link')
      .merge(links)
      .attr('x1', 30)
      .attr('y1', d => this.uniqueDepartments.indexOf(d.department) * departmentVertical)
      .attr('x2', rightIndent - leftIndent - 10)
      .attr('y2', d => this.uniquePrograms.indexOf(d.program) * programVertical)
      .style('stroke', d => this.departmentColorScale(d.department))
      .style('stroke-width', d => Math.max(d.submissions / 25, 1))
      .style('stroke-opacity', 0.3);

    links.exit().remove();
  }

  // Handle college selection event
  setupCollegeSelectionListener() {
    const collegeSelect = document.getElementById('college-select');

    collegeSelect.addEventListener('change', () => {
      const selectedCollege = collegeSelect.value;

      // Filter the data based on the selected college
      const filteredData = this.committeeData.filter(d => selectedCollege === '' || d.college === selectedCollege);
      // Update the graph with the filtered data
      this.updateGraph(filteredData);
    });
  }

  // Initialize the network graph
  initializeNetworkGraph() {
    console.log('Initializing network graph');

    this.loadCommitteeData();
    this.createUniqueDepartmentsAndPrograms();
    this.createSVG();
    this.setupCollegeSelectionListener();
  }
}

$(document).ready(() => {
  const networkGraph = new NetworkGraph();
  networkGraph.initializeNetworkGraph();
});
