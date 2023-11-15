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
    this.selectedNode = null;
    this.selectedLinks = [];
  }

  // Extract unique departments and programs, and set up color scale
  createUniqueDepartmentsAndPrograms(data = this.committeeData) {
    this.uniqueDepartments = Array.from(new Set(data.map(d => d.department))).sort();
    this.uniquePrograms = Array.from(new Set(data.map(d => d.program))).sort();
    this.departmentColorScale = d3.scaleOrdinal(d3.schemeCategory10).domain(this.uniqueDepartments);
  }

  // Load committee data from the DOM
  loadCommitteeData() {
    const networkGraphElement = document.getElementById('network-graph');

    if (!networkGraphElement) {
      console.error('Element with ID "network-graph" not found.');
      return;
    }

    this.committeeData = JSON.parse(networkGraphElement.getAttribute('data'));

    // Aggregating data by department, college, and program, summing submissions
    const aggregatedData = this.committeeData.reduce((accumulator, current) => {
      const { department, college, program, submissions } = current;
      const key = `${department}|${college}|${program}`;

      if (!accumulator[key]) {
        accumulator[key] = { department, college, program, submissions: 0 };
      }
      accumulator[key].submissions += submissions;

      return accumulator;
    }, {});

    this.committeeDataFull = this.committeeData;
    this.committeeData = Object.values(aggregatedData);
    this.createUniqueDepartmentsAndPrograms(this.committeeData);
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

    // Call add nodes and links to svg
    this.createDepartmentNodes();
    this.createProgramNodes();
    this.createLinks();
  }

  // Create department nodes
  createDepartmentNodes(data = this.uniqueDepartments, departmentVertical = 150, graphData = this.committeeData) {
    const departmentNodes = this.departmentSVG.selectAll('.department-node')
      .data(data)
      .enter()
      .append('g')
      .attr('class', 'department-node')
      .attr('font-size', '20px')
      .attr('transform', (d, i) => `translate(0, ${i * departmentVertical})`)
      .on('click', d => this.handleNodeClick(d, graphData));

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

    // add mouse over action
    departmentNodes.on('mouseover', function () {
      d3.select(this)
          .select('.department-circle')
          .attr('r', 18); // Enlarge the circle on mouseover

      d3.select(this)
          .select('.department-text')
          .append('title')
          .text("Click for more information"); // Tooltip message

      d3.select(this)
          .select('.department-text')
          .attr('font-weight', 'bold');
    })
    .on('mouseout', function () {
        d3.select(this)
            .select('.department-circle')
            .attr('r', 12); // Revert the circle size on mouseout

        d3.select(this)
            .select('.department-text')
            .select('title')
            .remove(); // Remove the tooltip on mouseout

      d3.select(this)
            .select('.department-text')
            .attr('font-weight', 'normal');
    });
  }

  // Create program nodes
  createProgramNodes(data = this.uniquePrograms, graphData = this.committeeData) {
    const programVertical = 100;

    const programNodes = this.programSVG.selectAll('.program-node')
        .data(data)
        .enter()
        .append('g')
        .attr('class', 'program-node')
        .attr('font-size', '20px')
        .attr('transform', (d, i) => `translate(0, ${i * programVertical})`)
        .on('click', d => this.handleNodeClick(d, graphData));

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

    // add mouse over action
    programNodes.on('mouseover', function () {
      d3.select(this)
          .select('.program-circle')
          .attr('r', 18); // Enlarge the circle on mouseover

      d3.select(this)
          .select('.program-text')
          .append('title')
          .text("Click for more information"); // Tooltip message

      d3.select(this)
          .select('.program-text')
          .attr('font-weight', 'bold');
    })
    .on('mouseout', function () {
        d3.select(this)
            .select('.program-circle')
            .attr('r', 12); // Revert the circle size on mouseout

        d3.select(this)
            .select('.program-text')
            .select('title')
            .remove(); // Remove the tooltip on mouseout

        d3.select(this)
            .select('.program-text')
            .attr('font-weight', 'normal');
    });
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
      .style('stroke-width', d => Math.max(d.submissions / 15, 1))
      .style('stroke-opacity', 0.3);
  }

  // Update the graph with filtered data
  updateGraph(filteredData) {
    console.log('updateGraph')
    // Recalculate unique departments and programs based on filtered data
    this.createUniqueDepartmentsAndPrograms(filteredData);

    // Calculate department and program vertical spacing based on the filtered data length
    const departmentVertical = (this.uniquePrograms.length / this.uniqueDepartments.length) * 100;

    // Remove existing department and program nodes
    this.departmentSVG.selectAll('.department-node').remove();
    this.programSVG.selectAll('.program-node').remove();

    // Recreate department and program nodes with filtered data
    this.createDepartmentNodes(this.uniqueDepartments, departmentVertical, filteredData);
    this.createProgramNodes(this.uniquePrograms, filteredData);

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
      .style('stroke-width', d => Math.max(d.submissions / 15, 1))
      .style('stroke-opacity', 0.3);

    links.exit().remove();
  }

  // Handle college selection event
  setupCollegeSelectionListener() {
    const collegeSelect = document.getElementById('college-select');
    const collegeTitle = document.getElementById('college-title');

    collegeSelect.addEventListener('change', () => {
      const selectedCollege = collegeSelect.value;

      // Filter the data based on the selected college
      const filteredData = this.committeeData.filter(d => selectedCollege === '' || d.college === selectedCollege);
      // The title is blank for "All Colleges", but changes for other colleges
      collegeTitle.textContent = selectedCollege === '' ? '' : `The chart reflects ${selectedCollege} faculty data.`;
      // Update the graph with the filtered data
      this.updateGraph(filteredData);
    });
  }

  createBarChart() {
    console.log('enter create bar chart');
    // Clear display
    const networkGraph = d3.select('#network-graph');
    networkGraph.style('display', 'none'); // Hide the network graph
    const departmentHeader = d3.select('#department-header');
    departmentHeader.style('display', 'none'); // Hide department header
    const programHeader = d3.select('#program-header');
    programHeader.style('display', 'none'); // Hide program header
    const collegeDropdown = d3.select('#college-dropdown-container');
    collegeDropdown.style('display', 'none'); // Hide program header
    const description = d3.select('#chart-description');
    description.style('display', 'none'); // Hide description

    const isDepartmentNode = this.selectedNodeIsDepartment;

    // Clean data
    const data = this.selectedLinks.map(link => ({
      name: isDepartmentNode ? link.program : link.department,
      submissions: link.submissions
    }));
    data.sort((a, b) => b.submissions - a.submissions);
    console.log('selected links: ', this.selectedLinks);
    console.log('data sorted: ', data);

    // Get selected college
    const selectedCollege = document.getElementById('college-select').value;

    // Create titles
    const title = isDepartmentNode ? `Publications for Faculty Department: ${this.selectedNode}` : `Publications for Student Program: ${this.selectedNode}`;
    const subtitle = selectedCollege ? `Selected Faculty College: ${selectedCollege}` : '';
    const yAxisLabel = isDepartmentNode ? 'Student Programs' : 'Faculty Department';

    // Find the number of bars
    const numBars = this.selectedLinks.length;

    const margin = { top: 150, right: 50, bottom: 20, left: 300 };
    const width = window.innerWidth - margin.left - margin.right;
    const height = Math.max(window.innerHeight, numBars * 100 + 200);

    // number of ticks
    const maxSubmissions = d3.max(this.selectedLinks, d => d.submissions);
    console.log(maxSubmissions)
    const numTicks = Math.min(maxSubmissions, numBars, 10);

    // Define the SVG element
    const svg = d3.select('#bar-chart')
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', `translate(${margin.left},${margin.top})`);

    const xScale = d3.scaleLinear()
      .domain([0, maxSubmissions])
      .range([0, width - margin.left - margin.right]);

    const yScale = d3.scaleBand()
      .domain(data.map(d => d.name))
      .range([0, height - margin.top - margin.bottom])
      .padding(0.1);

    // Position 'Back' button to return to the network graph
    const backButton = d3.select('#bar-chart')
      .append('span')
      .attr('class', 'back-button')
      .text('← Back')
      .attr('title', 'Return to Network Graph')
      .on('click', function () {
        // Remove the chart
        d3.select(this.parentNode).select('svg').remove();
        // Reset display
        networkGraph.style('display', 'block');
        departmentHeader.style('display', 'block'); // Show department header
        programHeader.style('display', 'block'); // Show program header
        collegeDropdown.style('display', 'block'); // Show college drop down
        description.style('display', 'block');
        // Remove the back button
        d3.select(this).remove();
      });

    backButton.style("float", "right").style("cursor", "pointer").style("position", "relative").style("top", "-20px");

    // Render bars and labels
    svg.append("g")
      .call(d3.axisTop(xScale).ticks(10).tickSize(-height).tickFormat(d3.format(".0f")))
      .attr("transform", `translate(0,0)`)
      .attr('font-size', '16px')
      .call(g => g.select(".domain").remove());

    svg.append("g")
      .call(d3.axisLeft(yScale).ticks(numTicks))
      .call(g => g.select(".domain").remove());

    svg.selectAll('.bar')
      .data(data)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', 0)
      .attr('y', d => yScale(d.name))
      .attr('width', d => xScale(d.submissions))
      .attr('height', yScale.bandwidth())
      .attr('fill', 'steelblue')
      .style('stroke-opacity', 0.2);

    svg.selectAll('.bar-label')
      .data(data)
      .enter()
      .append('text')
      .attr('class', 'bar-label')
      .attr('x', d => xScale(d.submissions) + 5)
      .attr('y', d => yScale(d.name) + yScale.bandwidth() / 2 + 5)
      .text(d => d.submissions)
      .attr('alignment-baseline', 'middle')
      .attr('font-size', '16px');

    // Append titles after bars and axes to display them on top
    svg.append('text')
      .text(title)
      .attr('x', 0)
      .attr('y', -80)
      .attr('font-size', '25px')
      .attr('font-weight', 'bold');

    svg.append('text')
      .text(subtitle)
      .attr('x', 0)
      .attr('y', -40)
      .attr('font-size', '16px');

    // Append Y-axis label
    svg.append('text')
      .text(yAxisLabel)
      .attr('transform', 'rotate(-90)')
      .attr('x', -height / 2)
      .attr('y', -270)
      .attr('font-size', '16px');
  }

  // Update function to handle node click event
  handleNodeClick(selectedNodeData, graphData) {
    console.log('Clicked node:', selectedNodeData);
    const selectedClass = selectedNodeData.originalTarget.attributes.class;
    const selectedName = selectedNodeData.originalTarget.__data__;

    // Binary indicator to show if the clicked node represents departments or programs
    const departmentBoolean = selectedClass.nodeValue.split('-')[0] == 'department';
    this.selectedNodeIsDepartment = departmentBoolean;

    // Update the selected node and its associated links
    this.selectedNode = selectedName;
    this.selectedLinks = graphData.filter(d => departmentBoolean ? d.department === selectedName : d.program === selectedName);
    console.log('Associated links:', this.selectedLinks);

    // Create bar chart with relevant filtered data
    this.createBarChart();
  }

  // Initialize Graph
  initializeNetworkGraph() {
    console.log('Initializing network graph');

    this.loadCommitteeData();
    this.createSVG();
    this.setupCollegeSelectionListener();
  }
}

$(document).ready(() => {
  const networkGraph = new NetworkGraph();
  networkGraph.initializeNetworkGraph();
});
