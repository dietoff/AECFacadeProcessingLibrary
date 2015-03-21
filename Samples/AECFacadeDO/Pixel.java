import java.util.ArrayList;
import java.util.HashMap;

public class Pixel {
	int id;
	int x;
	int y;
	int width;
	public Pixel top = null;
	public Pixel bottom = null;
	public Pixel left = null;
	public Pixel right = null;
	HashMap<String,Pixel> neighbors = new HashMap<String,Pixel>();
	public Boolean on = false;
	
	public Pixel(int id_, int x_, int y_, int w_) {
		id=id_;
		x=x_;
		y=y_;
		width = w_;
	}
	
	public void addNeighbor(String s, Pixel p) {
		if (s=="top") {
			neighbors.put("top", p);
			top=p;
		}
		if (s=="bottom") {
			neighbors.put("bottom", p);
			bottom=p;
		}
		if (s=="left") {
			neighbors.put("left", p);
			left=p;
		}
		if (s=="right") {
			neighbors.put("right", p);
			right=p;
		}
	}
	
	public HashMap<String, Pixel> getNeighbors() {
		return neighbors;
	}

}
