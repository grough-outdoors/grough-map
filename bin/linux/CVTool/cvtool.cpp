// CVLiDAR.cpp : Defines the entry point for the console application.
//

#include <imgproc/imgproc.hpp>
#include <highgui/highgui.hpp>
#include <photo/photo.hpp>

#include <iostream>
#include <vector>
#include <string>

void thinningIteration(cv::Mat& im, int iter)
{
	cv::Mat marker = cv::Mat::zeros(im.size(), CV_8UC1);

	for (int i = 1; i < im.rows - 1; i++)
	{
		for (int j = 1; j < im.cols - 1; j++)
		{
			uchar p2 = im.at<uchar>(i - 1, j);
			uchar p3 = im.at<uchar>(i - 1, j + 1);
			uchar p4 = im.at<uchar>(i, j + 1);
			uchar p5 = im.at<uchar>(i + 1, j + 1);
			uchar p6 = im.at<uchar>(i + 1, j);
			uchar p7 = im.at<uchar>(i + 1, j - 1);
			uchar p8 = im.at<uchar>(i, j - 1);
			uchar p9 = im.at<uchar>(i - 1, j - 1);

			int A = (p2 == 0 && p3 == 1) + (p3 == 0 && p4 == 1) +
				(p4 == 0 && p5 == 1) + (p5 == 0 && p6 == 1) +
				(p6 == 0 && p7 == 1) + (p7 == 0 && p8 == 1) +
				(p8 == 0 && p9 == 1) + (p9 == 0 && p2 == 1);
			int B = p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9;
			int m1 = iter == 0 ? (p2 * p4 * p6) : (p2 * p4 * p8);
			int m2 = iter == 0 ? (p4 * p6 * p8) : (p2 * p6 * p8);

			if (A == 1 && (B >= 2 && B <= 6) && m1 == 0 && m2 == 0)
				marker.at<uchar>(i, j) = 1;
		}
	}

	im &= ~marker;
	marker.release();
}

void thinning(cv::Mat& im, int maxForLines = 2)
{
	im /= 255;

	cv::Mat prev = cv::Mat::zeros(im.size(), CV_8UC1);
	cv::Mat diff;

	int iterations = 1;

	// Thinning that we use
	std::cout << "...starting thinning iterations...\n";
	do {
		std::cout << "...starting iteration " << iterations++ << "...\n";

		thinningIteration(im, 0);
		thinningIteration(im, 1);
		cv::absdiff(im, prev, diff);
		im.copyTo(prev);
	} while (cv::countNonZero(diff) > 0 && iterations <= maxForLines);

	im *= 255;
}

bool replace(std::string& str, const std::string& from, const std::string& to) {
    size_t start_pos = str.find(from);
    if(start_pos == std::string::npos)
        return false;
    str.replace(start_pos, from.length(), to);
    return true;
}

int main(int argc, char *argv[])
{
	uchar softwareMode = 0;
	
	if (strcmp(argv[2], "line") == 0) {
		softwareMode = 1;
	}

	if (strcmp(argv[2], "polygon") == 0) {
		softwareMode = 2;
	}
	
	if (softwareMode == 0) {
		std::cout << "Must specify either line or polygon as mode of operation.\n";
		return -1;
	}
	
	std::cout << "We're running...\n";

	std::string inFilename(argv[1]);
	std::string outFilename(argv[1]);
	
	if (softwareMode == 1) {
		std::cout << "Generating LINES...\n";
		replace(outFilename, ".", "_Skel.");
		
		std::cout << "Input file: " << inFilename << "\n";
		std::cout << "Output file: " << outFilename << "\n";
		
		cv::Mat bwImage = cv::imread(argv[1], CV_LOAD_IMAGE_GRAYSCALE);

		if (bwImage.empty())
		{
			std::cout << "Could not open source image.\n";
			return -1;
		}
		
		// ----
		// Create skeleton
		// ----
		std::cout << "Generating skeleton...\n";
		//cv::threshold(srcImage, srcImage, 1, 255, CV_THRESH_BINARY);
		thinning(bwImage, 4);	// Max iterations for thinning op

		//cv::imwrite("/vagrant/volatile/test_skel1.tif", bwImage);

		// ----
		// Create deletion mask
		// ----
		std::cout << "Generating deletion mask...\n";
		cv::Mat bwDeleteMask(bwImage.size(), CV_8UC1);
		cv::Mat matMorphDeletionDilate = cv::getStructuringElement(
			cv::MORPH_CROSS,
			cv::Size(3, 3),
			cv::Point(1, 1)
		);
		cv::morphologyEx(bwImage, bwDeleteMask, cv::MORPH_DILATE, matMorphDeletionDilate);

		cv::Mat matMorphDeletionClose = cv::getStructuringElement(
			cv::MORPH_CROSS,
			cv::Size(3, 3),
			cv::Point(1, 1)
		);
		cv::morphologyEx(bwDeleteMask, bwDeleteMask, cv::MORPH_CLOSE, matMorphDeletionClose);

		cv::Mat matMorphDeletionErode = cv::getStructuringElement(
			cv::MORPH_ELLIPSE,
			cv::Size(5, 5),
			cv::Point(2, 2)
		);
		cv::morphologyEx(bwDeleteMask, bwDeleteMask, cv::MORPH_ERODE, matMorphDeletionErode);

		bitwise_not(bwDeleteMask, bwDeleteMask);
		//cv::imwrite("/vagrant/volatile/test_delete_mask.tif", bwDeleteMask);

		bitwise_and(bwImage, bwDeleteMask, bwImage);
		//cv::imwrite("/vagrant/volatile/test_skel_masked.tif", bwImage);

		cv::threshold(bwImage, bwImage, 1, 255, CV_THRESH_BINARY);

		cv::resize(bwImage, bwImage, cv::Size(0, 0), 2.0, 2.0, CV_INTER_NN);
		cv::threshold(bwImage, bwImage, 25, 255, CV_THRESH_BINARY);

		cv::Mat matMorphGrow = cv::getStructuringElement(
			cv::MORPH_ELLIPSE,
			cv::Size(5, 5),
			cv::Point(2, 2)
		);
		std::cout << "Dilating...\n";
		cv::morphologyEx(bwImage, bwImage, cv::MORPH_DILATE, matMorphGrow);

		//cv::imwrite("/vagrant/volatile/test_dilated.tif", bwImage);

		std::cout << "Second skeleton...\n";
		thinning(bwImage, 10);	// Max iterations for thinning op

		std::cout << "Final output...\n";
		cv::imwrite(outFilename.c_str(), bwImage * 255);
	} else {
		std::cout << "Generating POLYGON...\n";
		
		replace(outFilename, ".", "_Mask.");
		
		std::cout << "Input file: " << inFilename << "\n";
		std::cout << "Output file: " << outFilename << "\n";
		
		cv::Mat bwImage = cv::imread(argv[1], CV_LOAD_IMAGE_GRAYSCALE);

		if (bwImage.empty())
		{
			std::cout << "Could not open source image.\n";
			return -1;
		}
	
		// Close to make areas
		cv::Mat matMorphPolyClose = cv::getStructuringElement(
			cv::MORPH_ELLIPSE,
			cv::Size(9, 9),
			cv::Point(4, 4)
		);
		cv::morphologyEx(bwImage, bwImage, cv::MORPH_CLOSE, matMorphPolyClose);
		//cv::imwrite("/vagrant/volatile/poly_close.tif", bwImage);
		
		// Open to remove lines
		cv::Mat matMorphPolyOpen = cv::getStructuringElement(
			cv::MORPH_ELLIPSE,
			cv::Size(11, 11),
			cv::Point(5, 5)
		);
		cv::morphologyEx(bwImage, bwImage, cv::MORPH_OPEN, matMorphPolyOpen);
		//cv::imwrite("/vagrant/volatile/poly_open.tif", bwImage);
		
		std::cout << "Final output...\n";
		bitwise_not(bwImage, bwImage);
		cv::imwrite(outFilename.c_str(), bwImage * 255);
	}

	return 0;
}

