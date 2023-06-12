// This script lets the user compute the distance between max and
// bottom point of the max peak in the plot profile of stack of images. 
// To run it, open any stack of images press run.

// You can and must modify three things to adjust it to your stack
//  1) First the range of slices to evaluate (start, end) 
//  2) Second, the pixel width that corresponds to your dataset
//  3) Third, (if using halfmax) the halfmax point, which, at the moment, is defined as
// the max value minus a percentage of the distance between the max
// and the min value found to the right of the maxval. (line 87)

// If you are studying fibers, locate the wall under study always
// at the right of the fiber, in vertical position. 

// ======= IF WANNA CREATE THE RESLICE WINDOW EVERYTIME, uncomment =====
//list = getList("image.titles");
//pattern = "eslice";

//found = false;
//for (i = 0; i < list.length; i++) {
//    if (list[i].contains(pattern)) {
//        found = true;
//        break;
//    }
//}
// If no window containing the pattern is found, execute the print statement
//if (!found) {
//    // Prepare stack
//    run("Reslice [/]...", "output=1.000 start=Right avoid");
//    run("Invert", "stack");
//}
// ======= IF WANNA CREATE THE RESLICE WINDOW EVERYTIME, end =====

// setTool("line");
// waitForUser("Please draw a line. Press Okay to continue...");
// Here you can draw a line or a square ROI for the plot profile

// Define the starting and ending positions for the slider
start = 0;             //CHANGE HERE first slide of the range to eval
end = 60;			   //CHANGE HERE last slide of the range to eval
pixelWidth = 0.035;   //CHANGE HERE the ratio (real distance / num pxls)

// Define an empty array to store the peak widths or oval contour thickness
widths = newArray(end - start + 1);
run("Clear Results");
// Loop through all the slices
// for (i=start; i<=end; i++) {
for (i=0; i<=15; i++) {
    // Set the slider position
    // setSlice(i);
    
    //Make selections:
    makeRectangle(626, 100+50*i, 236, 50); // CHANGE HERE rectangle params
    

    // Extract the plot profile or measure the oval contour thickness
    profile = getProfile();
    
    // Find the maximum value and its location
    maxVal = -1;
    maxPos = -1;
    for (j=0; j<profile.length; j++) {
        if (profile[j] > maxVal) {
            maxVal = profile[j];
            maxPos = j;
        }
    }
    setResult("Max", i-start, maxVal);
	updateResults;
	
    // Find the minimum value and its location
    minVal = 1000000;
    minPos = -1;
    for (j=maxPos; j<profile.length; j++) {
        if (profile[j] < minVal) {
            minVal = profile[j];
            minPos = j;
        }
    }
    setResult("Min", i-start, minVal);
    setResult("MinPos", i-start, minPos);
	updateResults;
	
	 // Find the point the max peak begins at from the right
	tolerance = 2; //(45º angle uf stiffness)
	peak_right_pos = -1;
    for (j=minPos; j>maxPos; j--) {
    	slope = (profile[j-1] - profile[j]); // Compute slope (Δy / Δx)
        if (slope > 2) {
            peak_right_pos = j;
            break;
        }
    }
	width = (peak_right_pos - maxPos)*pixelWidth;

    // Plot profile
    // Plot.create("Profile", "X", "Value", profile);

    // Find the points to measure peak-width
    // halfMax = (maxVal + minVal) / 2; <<--- This is the typical halfmax
    
    ////CHANGE HERE the percentage to subtract from the maxvalue
    //halfMax = maxVal - (maxVal-minVal) * 0.25; //   <<--------------
    //leftPos = -1;
    //rightPos = -1;
    //for (j=maxPos; j>=0; j--) {
    //    if (profile[j] < halfMax) {
    //        leftPos = j;
    //        break;
    //    }
    // }
    //for (j=maxPos; j<profile.length; j++) {
    //    if (profile[j] < halfMax) {
    //        rightPos = j;
    //        break;
    //    }
    //}
    //// Calculate the peak width or oval contour thickness
    //width = (rightPos - leftPos) * pixelWidth;
    widths[i - start] = width;
    setResult("Width", i-start, width);
	updateResults;
}

// Calculate the average width and standard deviation
// Compute the average of the array
sum = 0;
for (i = 0; i < widths.length; i++) {
    sum += widths[i];
}
average = sum / widths.length;
// Print the average to the console
print("Average: " + average);

// Compute the sum of the squares of the differences between each element and the mean
diffSum = 0;
for (i = 0; i < widths.length; i++) {
    diffSum += Math.pow(widths[i] - average, 2);
}

// Compute the standard deviation of the array
stdev = Math.sqrt(diffSum / (widths.length - 1));

// Print the standard deviation to the console
print("Standard deviation: " + stdev);

// Save as spreadsheet compatible text file
path = getDirectory("home")+"Desktop/Fiji Results/profile.csv";
saveAs("Results", path);