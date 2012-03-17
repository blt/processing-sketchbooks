// Largely developed using the example in Chapter 8 of Generative Art.

FractalRoot polygon;
int _maxlevels = 4;
int _numSides = 9;

void setup() {
    size(1000,1000);
    smooth();

    polygon = new FractalRoot();
    polygon.draw();
}

void keyPressed() {
    if (keyCode == ENTER) {
        saveFrame("screen-####.jpg");
    }
}

void draw() {
}

class PointObj {
    float x,y;
    PointObj(float ex, float why) {
        x=ex; y=why;
    }
}

class FractalRoot {
    PointObj[] pointArr = {};
    Branch rootBranch;

    FractalRoot() {
        float centX = width/2;
        float centY = height/2;
        int radius = 400;
        float angleStep = 360.0f/_numSides;

        for (int i=0; i<360; i+=angleStep) {
            float x = centX + (radius*cos(radians(i)));
            float y = centY + (radius*sin(radians(i)));
            pointArr = (PointObj[]) append(pointArr, new PointObj(x,y));
        }
        rootBranch = new Branch(0, 0, pointArr);
    }

    void draw() {
        rootBranch.draw();
    }
}

class Branch {
    int level, num;
    PointObj[] outerPoints={};
    PointObj[] midPoints={};
    PointObj[] projPoints={};
    Branch[] myBranches = {};

    Branch(int lev, int n, PointObj[] points) {
        level = lev;
        num = n;
        outerPoints = points;
        midPoints = calcMidPoints();
        projPoints = calcStrutPoints();

        if ((level+1) < _maxlevels) {
            Branch childBranch = new Branch(level+1, 0, projPoints);
            myBranches = (Branch[])append(myBranches, childBranch);

            for (int k=0; k<outerPoints.length; k++) {
                int nextk=k-1;
                if (nextk < 0) { nextk += outerPoints.length; }
                PointObj[] newPoints = { projPoints[k], midPoints[k],
                                         outerPoints[k], midPoints[nextk], projPoints[nextk] };
                childBranch = new Branch(level+1, k+1, newPoints);
                myBranches = (Branch[])append(myBranches, childBranch);
            }
        }
    }

    void draw() {
        strokeWeight((_maxlevels - level) * 0.1);

        // draw lines
        for(int i = 0; i<outerPoints.length; i++) {
            int nexti = i+1;
            if (nexti == outerPoints.length){ nexti = 0; }
            line(outerPoints[i].x, outerPoints[i].y, outerPoints[nexti].x, outerPoints[nexti].y);
        }


        for (int k=0; k < myBranches.length; k++) {
            myBranches[k].draw();
        }
    }

    PointObj[] calcMidPoints() {
        PointObj[] mpArray = new PointObj[outerPoints.length];
        for (int i=0; i<outerPoints.length; i++) {
            int nexti = i+1;
            if (nexti == outerPoints.length) { nexti = 0; }
            PointObj thisMP = calcMidPoint(outerPoints[i], outerPoints[nexti]);
            mpArray[i] = thisMP;
        }
        return mpArray;
    }

    PointObj calcMidPoint(PointObj end1, PointObj end2) {
        float mx, my;

        mx = (end1.x + end2.x)/2;
        my = (end1.y + end2.y)/2;

        return new PointObj(mx, my);
    }

    PointObj[] calcStrutPoints() {
        PointObj[] strutArray = new PointObj[midPoints.length];
        for (int i=0; i< midPoints.length; i++) {
            int nexti = i+3;
            if (nexti >= midPoints.length) { nexti -= midPoints.length; }
            PointObj thisSP = calcProjPoint(midPoints[i], outerPoints[nexti]);
            strutArray[i] = thisSP;
        }
        return strutArray;
    }

    PointObj calcProjPoint(PointObj mp, PointObj op) {
        float px, py;
        float adj, opp;
        float _strutFactor = 0.2;

        opp = abs(mp.x - op.x);
        adj = abs(mp.y - op.y);

        if (op.x > mp.x) {
            px = mp.x + (opp * _strutFactor);
        } else {
            px = mp.x - (opp * _strutFactor);
        }
        if (op.y > mp.y) {
            py = mp.y + (adj * _strutFactor);
        } else {
            py = mp.y - (adj * _strutFactor);
        }

        return new PointObj(px, py);
    }


}
