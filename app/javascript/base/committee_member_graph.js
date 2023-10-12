import $ from 'jquery';
import * as d3 from 'd3';

const chart = {

  initializeNetworkGraph: function () {
    const rawData = JSON.parse(document.getElementById("network-graph").getAttribute("data"));

    const nodes = {};
    const links = rawData.map(d => {
      const department = { id: d.department, type: 'department', name: d.department };
      const program = { id: d.program, type: 'program', name: d.program };

      nodes[d.department] = department;
      nodes[d.program] = program;

      return { source: d.department, target: d.program, count: d.submissions };
    });

    const svg = d3.select('#network-graph').append('svg')
      .attr('width', "100%")
      .attr('height', "100%")
      .attr("viewBox", [0, 0, 1000, 1000])
      .attr("style", "max-width: 100%; height: 100%;")
      .style("background-color", "black")
      .call(d3.zoom()
        .scaleExtent([1 / 5, 10])
        .on("zoom", zoomed))
      .append("g");

    const colorScale = d3.scaleOrdinal()
      .domain(['department', 'program'])
      .range(['blue', 'green']);

    function zoomed(event) {
      svg.attr("transform", event.transform);
    }

    const simulation = d3.forceSimulation()
      .nodes(Object.values(nodes))
      .force('link', d3.forceLink(links).id(d => d.id).distance(100))
      .force('charge', d3.forceManyBody().strength(d => (d.type === 'department' ? -2000 : -500)))
      .on('tick', () => {
        link
          .attr("x1", d => d.source.x)
          .attr("y1", d => d.source.y)
          .attr("x2", d => d.target.x)
          .attr("y2", d => d.target.y);

        node
          .attr("transform", d => `translate(${d.x},${d.y})`);
      });

    const link = svg.selectAll("line")
      .data(links)
      .enter().append("line")
      .attr("stroke", "#999")
      .attr("stroke-opacity", 0.6)
      .attr("stroke-width", 1);

    const node = svg.selectAll(".node")
      .data(Object.values(nodes))
      .enter().append("g")
      .attr("class", "node")
      .each(function(d) {
        if (d.type === 'department') {
          d3.select(this)
            .append("rect")
            .attr("rx", 10)
            .attr("ry", 10)
            .attr("position", "middle");
        } else {
          d3.select(this)
            .append("circle")
            .attr("r", 40);
        }
      });


    node.append("text")
      .attr("dy", ".35em")
      .attr("text-anchor", "middle")
      .attr("style", "color:#FFFFFF;")
      .text(d => d.name);

    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }

    function dragged(event) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
    }

    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }

    node.call(d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended));
  }
};

$(document).ready(() => {
  chart.initializeNetworkGraph();
});
