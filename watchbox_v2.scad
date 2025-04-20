////////////////////////////////////////////////////////////
// WATCH BOX 2.0            //
////////////////////////////////////////////////////////////

//--------------------------------------------------------//
//                   USER PARAMETERS                      //
//--------------------------------------------------------//
numCols            = 5;       // pockets along X
numRows            = 2;       // pockets along Y

compartmentWidth   = 45;      // internal width  (X)
compartmentHeight  = 82;      // internal height (Y)
compartmentDepth   = 40;      // internal depth  (Z) - open top
innerDepth         = 40;

bottomThickness    = 2;       // thickness of bottom floor
wallThickness      = 2;       // outer walls
dividerThickness   = 1.5;     // thickness of internal dividers

// Stacking Aligner
pegDiameter        = 20;

// For visual smoothness
$fn = 64;  // Increase to 64 or more for smoother cylinders

//--------------------------------------------------------//
//       CALCULATE OVERALL BOX DIMENSIONS (X, Y, Z)       //
//--------------------------------------------------------//
// The "footprint" (X×Y) includes:
//  - Each pocket's width or height
//  - Divider thickness between pockets
//  - Outer walls on left/right or top/bottom

// in X direction:
outerWidth = 
    numCols * compartmentWidth
  + (numCols + 1) * dividerThickness
  + 2 * wallThickness;

// in Y direction:
outerHeight = 
    numRows * compartmentHeight
  + (numRows + 1) * dividerThickness
  + 2 * wallThickness;

// in Z direction, we have a 2 mm bottom plus 65 mm tall side walls = 67 mm
outerDepth = bottomThickness + compartmentDepth;  // e.g. 2 + 65 = 67

//--------------------------------------------------------//
//            MAIN BOX (OPEN AT THE TOP)                  //
//--------------------------------------------------------//
module watch_box() {
    difference() {
        //
        // 1) Solid outer prism
        //
        translate([-outerWidth/2, -outerHeight/2, 0])
            cube([outerWidth, outerHeight, outerDepth]);

        // 2) Subtract the 10 pockets. 
        //    Each pocket extends from z=bottomThickness (the top of the floor)
        //    up to z=bottomThickness + 65 = 67 (i.e. open at top).
        //
        for (row = [0 : numRows-1]) {
            for (col = [0 : numCols-1]) {
                
                // Pocket's lower-left corner in X and Y:
                px = -outerWidth/2 
                     + wallThickness 
                     + dividerThickness
                     + col*(compartmentWidth + dividerThickness);
                py = -outerHeight/2 
                     + wallThickness
                     + dividerThickness
                     + row*(compartmentHeight + dividerThickness);
                
                translate([px, py, bottomThickness+1]) {
                    cube([compartmentWidth, compartmentHeight, compartmentDepth]);
                }
            }
        }
        translate([(-outerWidth/2)+(2*wallThickness), (-outerHeight/2)+(2*wallThickness), innerDepth+1])
            cube([outerWidth-(4*wallThickness), outerHeight-(4*wallThickness), outerDepth-innerDepth ]);
    }
}
//--------------------------------------------------------//
//         BOTTOM RECESSES (matching holes)               //
//--------------------------------------------------------//
module pegs() {
      translate([-outerWidth/2, outerHeight/4, outerDepth])
            rotate([0,90,0]) cylinder(h=wallThickness,d=pegDiameter);
      translate([-outerWidth/2, -outerHeight/4, outerDepth])
            rotate([0,90,0]) cylinder(h=wallThickness,d=pegDiameter);
      translate([outerWidth/2-wallThickness, -outerHeight/4, outerDepth])
            rotate([0,90,0]) cylinder(h=wallThickness,d=pegDiameter);
      translate([outerWidth/2-wallThickness, outerHeight/4, outerDepth])
            rotate([0,90,0]) cylinder(h=wallThickness,d=pegDiameter);
    }

module cornerpegs() {
    module pegunit() {
        intersection(){
            scale([1,1,0.5]) sphere(d=pegDiameter);
            difference(){
                translate([0,0,-20])cube([50,50,50]);
                translate([wallThickness,wallThickness,-21]) cube([50-wallThickness,50-wallThickness,400]);
            };
        };
    };
      translate([-outerWidth/2, outerHeight/2, outerDepth]) rotate([0,0,270]) pegunit();
      translate([-outerWidth/2, -outerHeight/2, outerDepth]) rotate([0,0,0])  pegunit();
      translate([outerWidth/2, -outerHeight/2, outerDepth])  rotate([0,0,90]) pegunit();
      translate([outerWidth/2, outerHeight/2, outerDepth])  rotate([0,0,180]) pegunit();
    }
//--------------------------------------------------------//
//          COMBINE EVERYTHING INTO ONE OBJECT            //
//--------------------------------------------------------//
difference(){
    union() {
    // 1) The main watch box body (open at top)
    watch_box();
    cornerpegs();
    };
    translate([0,0,-outerDepth])cornerpegs();
    for (col = [1,3]) {
        echo(col);
        echo((outerWidth/numCols)*col);
        translate([-(outerWidth/2.5)+((outerWidth/numCols)*(col)),outerHeight/2+(outerHeight/4),outerDepth/2]) rotate([90,0,0]) cylinder(h=100,d=20);
        translate([-(outerWidth/2.5)+((outerWidth/numCols)*(col)),-(outerHeight/3),outerDepth/2]) rotate([90,0,0]) cylinder(h=100,d=20);
    };
    for (row = [-1,1]) {
        translate([-(outerWidth/1.2),row*outerHeight/4,outerDepth/2])  rotate([90,0,90]) cylinder(h=100,d=20);
        translate([(outerWidth*0.4),row*outerHeight/4,outerDepth/2])  rotate([90,0,90]) cylinder(h=100,d=20);
    };
};