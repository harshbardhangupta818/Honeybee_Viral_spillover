

String[] hostLabels; // Array to store host labels
ArrayList<float[][]> transmissionRatesList = new ArrayList<float[][]>(); // List to store transmission rates for each virus
int maxHostLabels = 0; // Maximum number of host labels among all text files
float cutoff = 1.01; // Transmission rate cutoff
float map_value = 2.0;
float textsize_BF = 30;
float textsize_host = 30;
String heading = "DWV Hosts Transmission Map";
String[] virus = {"Deformed Wing Virus"};

void setup() {
  size(1000, 800);
  background(255);

  // Load the text files for each virus
  String[] filenames = {
    "/Users/hbg/Documents/filtered_contigs/first_alignment_60/Beast_results_2/DWV/DWV_host.txt",
  };

  for (String filename : filenames) {
    String[] lines = loadStrings(filename);
    extractData(lines);
  }

  // Visualize the combined circular flow diagram
  visualizeCombinedFlow();

  // Display header text
  drawHeader();
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
    float diameter = min(width, height) * 0.8; // Adjusted diameter to fit within the canvas
    float angleIncrement = TWO_PI / maxHostLabels; // Use maxHostLabels

    // Calculate endX and endY based on angle and radius for each host label
    float[][] endPoints = new float[maxHostLabels][2];
    for (int i = 0; i < maxHostLabels; i++) {
      float labelAngle = i * angleIncrement;
      endPoints[i][0] = width / 2 + cos(labelAngle) * diameter / 2; // Adjusted radius
      endPoints[i][1] = height / 2 + sin(labelAngle) * diameter / 2; // Adjusted radius
    }

    // Add labels for hosts
    textSize(textsize_host * (width / 800)); // Set the font size proportional to canvas size
    float[] adjustX = {60,0,-80,0, 30};
    float[] adjustY = {0,40,0,-40,-20};
    for (int i = 0; i < maxHostLabels; i++) { // Use maxHostLabels
      float labelX = endPoints[i][0] + adjustX[i] * (width / 800);
      float labelY = endPoints[i][1] + adjustY[i] * (width / 800);
      textAlign(CENTER, CENTER);
      fill(100);
      String[] parts = split(hostLabels[i], ' ');
      for (int k = 0; k < parts.length; k++) {
        text(parts[k], labelX + 10 , labelY + 10 - (parts.length - k - 1) * 35 * (width / 800));
      }
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
            color[] virusColors = {color(150,0,0)}; // Example colors, modify as needed
            // Interpolate color based on virus index
            if (v < virusColors.length - 1) {
              arrowColor = lerpColor(virusColors[v], virusColors[v + 1], (float) v / (virusColors.length - 1));
            } else {
              arrowColor = virusColors[v];
            }

            float angletilt = map(v, 0, 1, 20, 50);
            float arrowWidth = map(transmissionRates[i][j], 0, 1, 1, map_value); // Scale transmission rate to arrow width
            drawArrow(startX, startY, endX, endY, arrowColor, arrowWidth * (width / 800), transmissionRates[i][j], angletilt * (width / 800), v);
          }
        }
      }
    }
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
  float arrowSize = 8 * (width / 800); // Size of the arrowhead adjusted based on canvas size
  beginShape();
  vertex(-arrowSize, arrowSize / 2);
  vertex(0, 0);
  vertex(-arrowSize, -arrowSize / 2);
  endShape(CLOSE);
  popMatrix();

  // Display transmission rate text near the arrow
  fill(80, 175, 0);
  textSize(textsize_BF * (width / 800)); // Font size adjusted based on canvas size
  textAlign(CENTER, CENTER);
  float textX = (startX + curveControlX) / 2 + 20 * (width / 800);
  float textY = (startY + curveControlY) / 2 - 15 * (width / 800);
  text(nf(transmissionRate, 0, 1), textX, textY);

  float labelY = height - 50 - ( virusIndex) * 40 * (width / 800);

  // Draw color label in the left bottom corner
  fill(arrowColor);
  rect(20 * (width / 800), labelY, 30 * (width / 800), 30 * (width / 800));
  fill(0);
  textSize(20 * (width / 800));
  textAlign(LEFT, CENTER);
  text(virus[virusIndex], 60 * (width / 800), labelY + 15 * (width / 800));
}

void drawHeader() {
  fill(0);
  textSize(30 * (width / 800)); // Font size adjusted based on canvas size
  textAlign(CENTER, TOP);
  text(heading, width/2, 5);
}
