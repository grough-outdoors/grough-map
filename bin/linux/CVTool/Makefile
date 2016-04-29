CPP := g++
LIBS := `pkg-config --libs opencv`
CC_FLAGS := -I/usr/include/opencv2/

clean:
	find . -name *.o -execdir rm {} \;
	rm -rf CVLiDAR

% : %.cpp
	$(CPP) $< $(CC_FLAGS) $(LIBS) -o $@ 
