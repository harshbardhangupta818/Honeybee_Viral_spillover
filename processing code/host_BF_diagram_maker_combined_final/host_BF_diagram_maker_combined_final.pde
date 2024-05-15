import processing.pdf.*;

color c1 = #a6cee3;
color c3 = #1f78b4;
color c2 = #b2df8a;
color c5 = #33a02c;
color c4 = #fb9a99;
color c7 = #e31a1c;
color c6 = #fdbf6f;
color c9 = #ff7f00;
color c8 = #cab2d6;
color c10 = #6a3d9a;
color c11 = #5E4FA2;

String[] hostLabels; // Array to store host labels
ArrayList<float[][]> transmissionRatesList = new ArrayList<float[][]>(); // List to store transmission rates for each virus
int maxHostLabels = 0; // Maximum number of host labels among all text files
float cutoff = 1.01; // Transmission rate cutoff
float map_value = 1.5;
float textsize_BF = 15;
float textsize_host = 30;
String[] virus = {"Sacbrood Virus","Deformed Wing Virus","Tobacco Ringspot Virus", "Chronic Bee Paralysis Virus", "Kashmeer Bee Virus","Israeli Acute Paralysis virus", "Kakugo Virus","Acute Bee Paralysis Virus","Black Queen Cell Virus","Lake Sinai Virus"};

void setup() {
  size(1700, 1200);
  background(255);
    
  beginRecord(PDF, "Host_transmission_map_2.pdf");

  // Load the text files for each virus
  String[] filenames = {
    "/Users/hbg/Documents/host_map/SV_host.txt",
    "/Users/hbg/Documents/host_map/DWV_host.txt",
    "/Users/hbg/Documents/host_map/TRSV_host.txt",
    "/Users/hbg/Documents/host_map/CBPV_host.txt",
    "/Users/hbg/Documents/host_map/KBV_host.txt",
    "/Users/hbg/Documents/host_map/IAPV_host.txt",
    "/Users/hbg/Documents/host_map/KV_host.txt",
    "/Users/hbg/Documents/host_map/ABPV_host.txt",
    "/Users/hbg/Documents/host_map/BQCV_host.txt",
    "/Users/hbg/Documents/host_map/LSV_host.txt",
  };

  for (String filename : filenames) {
    String[] lines = loadStrings(filename);
    extractData(lines);
  }

  // Visualize the combined circular flow diagram
  visualizeCombinedFlow();

  // Display header text
  drawHeader();
  endRecord();
  save("Host_transmission_map_2.png");
}

void extractData(String[] lines) {
  if (lines != null && lines.length > 1) {
    // Extract labels and transmission rates
    ArrayList<String> labelsList = new ArrayList<String>();
    float[][] rates = new float[lines.length - 1][lines.length - 1]; // Square matrix
    
    // Start reading from the second row (index 1) to skip the header
    for (int i = 1; i < lines.length; i++) {
      // Split the line using tab delimiter
      String[] parts = split(lines[i], '\t');
      
      // Extract labels and transmission rate
      String labelFrom = parts[0];
      String labelTo = parts[1];
      float rate = float(parts[2]);
      
      // Add labels to the list if not already present
      if (!labelsList.contains(labelFrom)) {
        labelsList.add(labelFrom);
      }
      if (!labelsList.contains(labelTo)) {
        labelsList.add(labelTo);
      }
      
      // Add transmission rate to the rates array
      int fromIndex = labelsList.indexOf(labelFrom);
      int toIndex = labelsList.indexOf(labelTo);
      rates[fromIndex][toIndex] = log(rate);
    }
    
    // Determine maximum number of host labels
    maxHostLabels = max(maxHostLabels, labelsList.size());
    
    // Initialize hostLabels and add to transmissionRatesList
    hostLabels = labelsList.toArray(new String[labelsList.size()]);
    transmissionRatesList.add(rates);
  }
}



 void visualizeCombinedFlow() {
  if (hostLabels != null && transmissionRatesList.size() > 0) {
    float diameter = min(width, height) * 0.9; // Adjusted diameter to fit within the canvas
    float angleIncrement = TWO_PI / maxHostLabels; // Use maxHostLabels

    // Calculate endX and endY based on angle and radius for each host label
    float[][] endPoints = new float[maxHostLabels][2];
    for (int i = 0; i < maxHostLabels; i++) {
      float labelAngle = i * angleIncrement;
      endPoints[i][0] = width / 2 + cos(labelAngle) * diameter / 2; // Adjusted radius
      endPoints[i][1] = height / 2 + sin(labelAngle) * diameter / 2; // Adjusted radius
    }

    // Add labels for hosts
    textSize(textsize_host * (width / 1200)); // Set the font size proportional to canvas size
    float[] adjustX = {100,0,-10,-50,0}; // Adjusted X positions for 5 labels
    float[] adjustY = {0,20,20,0,-20}; // Adjusted Y positions for 5 labels
    for (int i = 0; i < maxHostLabels; i++) { // Use maxHostLabels
      float labelX = endPoints[i][0] + adjustX[i] * (width / 1200);
      float labelY = endPoints[i][1] + adjustY[i] * (width / 1200);
      textAlign(CENTER, CENTER);
      fill(100);
      text(hostLabels[i], labelX, labelY);
    }

    // Draw curved arrows between hosts and add transmission rate text for each virus
    for (int v = 0; v < transmissionRatesList.size(); v++) { // Loop through each virus
      float[][] transmissionRates = transmissionRatesList.get(v);

      for (int i = 0; i < maxHostLabels; i++) { // Use maxHostLabels
        for (int j = 0; j < maxHostLabels; j++) { // Use maxHostLabels
          if (i != j && transmissionRates[i][j] >= cutoff) { // Check if transmission rate is above cutoff
            float startX = endPoints[i][0];
            float startY = endPoints[i][1];
            float endX = endPoints[j][0];
            float endY = endPoints[j][1];

            // Choose color based on virus
            color arrowColor;
            color[] virusColors = {c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11}; // Example colors, modify as needed
            // Interpolate color based on virus index
            if (v < virusColors.length - 1) {
              arrowColor = lerpColor(virusColors[v], virusColors[v + 1], (float) v / (virusColors.length - 1));
            } else {
              arrowColor = virusColors[v];
            }

            float angletilt = map(v, 0, 1, 5, 25);
            float arrowWidth = map(transmissionRates[i][j], 0, 1, 1, map_value); // Scale transmission rate to arrow width
            drawArrow(startX, startY, endX, endY, arrowColor, arrowWidth * (width / 1200), transmissionRates[i][j], angletilt * (width / 1200), v);
          }
        }
      }
    }
    
    // Draw arrow thickness scale bar
    float scaleBarX = width - 250 * (width / 1200);
    float scaleBarY = 100 * (width / 1200);
    textSize(30 * (width / 1200));
    textAlign(LEFT, CENTER);
    text("Bayes Factor", scaleBarX + 60, scaleBarY - 30);
    textSize(25 * (width / 1200));
    float scaleBarHeight = 300 * (width / 1200);
    for (int i = 1; i < 16; i+=2) {
      float yPos = scaleBarY + i * (scaleBarHeight / 20);
      float lineWidth = map(i, 0, 1, 1, map_value);
      stroke(0);
      strokeWeight(lineWidth);
      line(scaleBarX, yPos, scaleBarX + 50 * (width / 1200), yPos);
      stroke(255);
      //line(scaleBarX + 50 * (width / 1200), yPos, scaleBarX + 50 * (width / 1200) + lineWidth, yPos);
    }
    fill(0);
    textSize(20 * (width / 1200));
    textAlign(LEFT, CENTER);
    for (int i = 1; i <16; i+=2) {
      float yPos = scaleBarY + i * (scaleBarHeight / 20);
      text(exp(i), scaleBarX + 70 * (width / 1200), yPos);}
     
  }
}



void drawArrow(float startX, float startY, float endX, float endY, color arrowColor, float arrowWidth, float transmissionRate, float ang, int virusIndex) {
  float arrowAngle = atan2(endY - startY, endX - startX);

  strokeWeight(arrowWidth);
  stroke(arrowColor);
  noFill();


  // Calculate the angle difference between start and end angles
  float angleDifference = atan2(sin(PI + arrowAngle), cos(PI + arrowAngle));

  // Draw the curved arrow
  float curveControlX = (startX + endX) / 2 + cos(arrowAngle - PI/2) * ang; // Adjust control point position
  float curveControlY = (startY + endY) / 2 + sin(arrowAngle - PI/2) * ang; // Adjust control point position
  bezier(startX, startY, curveControlX, curveControlY, curveControlX, curveControlY, endX, endY);

  // Calculate the position of the arrow head at the midpoint of the bezier curve
  float arrowHeadX = bezierPoint(startX, curveControlX, curveControlX, endX, 0.5);
  float arrowHeadY = bezierPoint(startY, curveControlY, curveControlY, endY, 0.5);

  // Draw the arrow head
  pushMatrix();
  translate(arrowHeadX, arrowHeadY);
  rotate(arrowAngle);
  float arrowSize = 8 * (width / 1200); // Size of the arrowhead adjusted based on canvas size
  beginShape();
  vertex(-arrowSize, arrowSize / 2);
  vertex(0, 0);
  vertex(-arrowSize, -arrowSize / 2);
  endShape(CLOSE);
  popMatrix();

  
  float labelY = 800 - ( virusIndex) * 40 * (width / 1200);

  // Draw color label in the left bottom corner
  fill(arrowColor);
  rect(20 * (width / 1200), labelY, 30 * (width / 1200), 30 * (width / 1200));
  fill(0);
  textSize(20 * (width / 1200));
  textAlign(LEFT, CENTER);
  text(virus[virusIndex], 60 * (width / 1200), labelY + 15 * (width / 1200));
  
  
}

void drawHeader() {
  fill(0);
  textSize(40 * (width / 1200)); // Font size adjusted based on canvas size
}
