// Parametric ish tray for holding things.


// You'll need a tray.
//
// This will draw a tray 90x40x35mm
// The walls of the tray will be 2.5mm in thickness
// The hooks attached to the tray will be 55mm in height
// The tray will be printed with an open face (the true part)
// The tray will be printed with a honeycomb patterned base
//

// Length of the box along the horizontal axis of the pegboard (mm)
length=90; 

// Height of the box along the vertical axis of the pegboard (mm)
height=35;

// Depth of storage in the box out from the pegboard (mm)
depth=40; 

// Thickness of the box walls (mm)
wall=2.5;

// Height of the hooks above the top of the box (mm)
hooks=height+20;

// The box can have an open face or a closed one (true or false)
open="true";  // [true, false]

tray(length, depth, height, wall, hooks, (open == "true"));


module boxhook(length) {
  unit = 5;  // 0.5 mm is ths size of the smallest feature 
  width= 4.25; // optimal width for Skadis in mm

    linear_extrude(width) {
        round2d(2,1) { 
          if (length >= 50) {
            // if the hook is to be long, then put a blip on it like so that it slots
            // in well and solidly to the board
            polygon([[0,0],[0,15],[40,15],[40,5],[35.5,5],[35.5,10],[5,10],[5,5],[10,5],[16,0]]);
            polygon([[40,15],[length, 15],[length, 10], [40,10]]);
          } else {    
            // if the hook it to be less than 50mm in length then no need for a blip
            polygon([[0,0],[0,15],[length,15],[length,10],[5,10],[5,5],[10,5],[16,0]]);
          }
        }
    };
}

module hooks(length, depth, height, wt) {
    // The hooks need to have 75mm between them to fit the board
    hook_separation = 75;
    hook_width = 4.25;

    first_hook_x = (length - hook_separation) / 2;
    second_hook_x = first_hook_x + hook_separation + hook_width;

    translate([first_hook_x,depth+10+wt,height]) rotate(a=[0, 90, 180]) boxhook(height);
    translate([second_hook_x,depth+10+wt,height]) rotate(a=[0, 90, 180]) boxhook(height);
}

module tray(x,y,z,wt,hl,open_face=true) {
    difference() {
        // basic cuboid shape
        cube([x, y, z]);

        // cut out the space from the basic cuboid shape
        // to make the tray
        translate([wt,wt,0]) { 
            cube([x - wt * 2, y - wt * 2, z]);
        }
        
        if (open_face) {
            difference() {
                translate([0, 0, z / 4]) {                
                    // cut out part of the front face to reduce material
                    cube([x, y - wt, z / 1.5]);
                };

                // rigidity supports are useful to keep the shape if 
                // content is a little weighty
                translate([0,0,0]) cube([wt, wt, z]);
                translate([x-wt, 0, 0]) cube([wt, wt, z]);
            }
        };
    }

    hooks(x, y, hl, wt);
    hexwall(x, y, wt*10); // these units are not consistent I know.
};


//////////// 3rd Party Contributing modules and functions below //////////


//////////////// ROUND ANYTHING

// Library: round-anything
// Version: 1.0
// Author: IrevDev
// Contributors: TLC123
// Copyright: 2017
// License: GPL 3


function polyRound(radiipoints,fn=5,mode=0)=
  /*Takes a list of radii points of the format [x,y,radius] and rounds each point
    with fn resolution
    mode=0 - automatic radius limiting - DEFAULT
    mode=1 - Debug, output radius reduction for automatic radius limiting
    mode=2 - No radius limiting*/
  let(
    getpoints=mode==2?1:2,
    p=getpoints(radiipoints), //make list of coordinates without radii
    Lp=len(p),
    //remove the middle point of any three colinear points
    newrp=[
      for(i=[0:len(p)-1]) if(isColinear(p[wrap(i-1,Lp)],p[wrap(i+0,Lp)],p[wrap(i+1,Lp)])==0||p[wrap(i+0,Lp)].z!=0)radiipoints[wrap(i+0,Lp)] 
    ],
    newrp2=processRadiiPoints(newrp),
    temp=[
      for(i=[0:len(newrp2)-1]) //for each point in the radii array
      let(
        thepoints=[for(j=[-getpoints:getpoints])newrp2[wrap(i+j,len(newrp2))]],//collect 5 radii points
        temp2=mode==2?round3points(thepoints,fn):round5points(thepoints,fn,mode)
      )
      mode==1?temp2:newrp2[i][2]==0?
        [[newrp2[i][0],newrp2[i][1]]]: //return the original point if the radius is 0
        CentreN2PointsArc(temp2[0],temp2[1],temp2[2],0,fn) //return the arc if everything is normal
    ]
  )
  [for (a = temp) for (b = a) b];//flattern and return the array

function round5points(rp,fn,debug=0)=
	rp[2][2]==0&&debug==0?[[rp[2][0],rp[2][1]]]://return the middle point if the radius is 0
	rp[2][2]==0&&debug==1?0://if debug is enabled and the radius is 0 return 0
	let(
    p=getpoints(rp), //get list of points
    r=[for(i=[1:3]) abs(rp[i][2])],//get the centre 3 radii
    //start by determining what the radius should be at point 3
    //find angles at points 2 , 3 and 4
    a2=cosineRuleAngle(p[0],p[1],p[2]),
    a3=cosineRuleAngle(p[1],p[2],p[3]),
    a4=cosineRuleAngle(p[2],p[3],p[4]),
    //find the distance between points 2&3 and between points 3&4
    d23=pointDist(p[1],p[2]),
    d34=pointDist(p[2],p[3]),
    //find the radius factors
    F23=(d23*tan(a2/2)*tan(a3/2))/(r[0]*tan(a3/2)+r[1]*tan(a2/2)),
    F34=(d34*tan(a3/2)*tan(a4/2))/(r[1]*tan(a4/2)+r[2]*tan(a3/2)),
    newR=min(r[1],F23*r[1],F34*r[1]),//use the smallest radius
    //now that the radius has been determined, find tangent points and circle centre
    tangD=newR/tan(a3/2),//distance to the tangent point from p3
      circD=newR/sin(a3/2),//distance to the circle centre from p3
    //find the angle from the p3
    an23=getAngle(p[1],p[2]),//angle from point 3 to 2
    an34=getAngle(p[3],p[2]),//angle from point 3 to 4
    //find tangent points
    t23=[p[2][0]-cos(an23)*tangD,p[2][1]-sin(an23)*tangD],//tangent point between points 2&3
    t34=[p[2][0]-cos(an34)*tangD,p[2][1]-sin(an34)*tangD],//tangent point between points 3&4
    //find circle centre
    tmid=getMidpoint(t23,t34),//midpoint between the two tangent points
    anCen=getAngle(tmid,p[2]),//angle from point 3 to circle centre
    cen=[p[2][0]-cos(anCen)*circD,p[2][1]-sin(anCen)*circD]
  )
    //circle center by offseting from point 3
    //determine the direction of rotation
	debug==1?//if debug in disabled return arc (default)
    (newR-r[1]):
	[t23,t34,cen];

function round3points(rp,fn)=
  rp[1][2]==0?[[rp[1][0],rp[1][1]]]://return the middle point if the radius is 0
	let(
    p=getpoints(rp), //get list of points
	  r=rp[1][2],//get the centre 3 radii
    ang=cosineRuleAngle(p[0],p[1],p[2]),//angle between the lines
    //now that the radius has been determined, find tangent points and circle centre
	  tangD=r/tan(ang/2),//distance to the tangent point from p2
    circD=r/sin(ang/2),//distance to the circle centre from p2
    //find the angles from the p2 with respect to the postitive x axis
    a12=getAngle(p[0],p[1]),//angle from point 2 to 1
    a23=getAngle(p[2],p[1]),//angle from point 2 to 3
    //find tangent points
    t12=[p[1][0]-cos(a12)*tangD,p[1][1]-sin(a12)*tangD],//tangent point between points 1&2
    t23=[p[1][0]-cos(a23)*tangD,p[1][1]-sin(a23)*tangD],//tangent point between points 2&3
    //find circle centre
    tmid=getMidpoint(t12,t23),//midpoint between the two tangent points
    angCen=getAngle(tmid,p[1]),//angle from point 2 to circle centre
    cen=[p[1][0]-cos(angCen)*circD,p[1][1]-sin(angCen)*circD] //circle center by offseting from point 2 
  )
	[t12,t23,cen];

function parallelFollow(rp,thick=4,minR=1,mode=1)=
    //rp[1][2]==0?[rp[1][0],rp[1][1],0]://return the middle point if the radius is 0
    thick==0?[rp[1][0],rp[1][1],0]://return the middle point if the radius is 0
	let(
    p=getpoints(rp), //get list of points
	  r=thick,//get the centre 3 radii
    ang=cosineRuleAngle(p[0],p[1],p[2]),//angle between the lines
    //now that the radius has been determined, find tangent points and circle centre
    tangD=r/tan(ang/2),//distance to the tangent point from p2
  	sgn=CWorCCW(rp),//rotation of the three points cw or ccw?let(sgn=mode==0?1:-1)
    circD=mode*sgn*r/sin(ang/2),//distance to the circle centre from p2
    //find the angles from the p2 with respect to the postitive x axis
    a12=getAngle(p[0],p[1]),//angle from point 2 to 1
    a23=getAngle(p[2],p[1]),//angle from point 2 to 3
    //find tangent points
    t12=[p[1][0]-cos(a12)*tangD,p[1][1]-sin(a12)*tangD],//tangent point between points 1&2
	  t23=[p[1][0]-cos(a23)*tangD,p[1][1]-sin(a23)*tangD],//tangent point between points 2&3
    //find circle centre
    tmid=getMidpoint(t12,t23),//midpoint between the two tangent points
    angCen=getAngle(tmid,p[1]),//angle from point 2 to circle centre
    cen=[p[1][0]-cos(angCen)*circD,p[1][1]-sin(angCen)*circD],//circle center by offseting from point 2 
    outR=max(minR,rp[1][2]-thick*sgn*mode) //ensures radii are never too small.
  )
	concat(cen,outR);

function findPoint(ang1,refpoint1,ang2,refpoint2,r=0)=
  let(
    m1=tan(ang1),
    c1=refpoint1.y-m1*refpoint1.x,
	  m2=tan(ang2),
    c2=refpoint2.y-m2*refpoint2.x,
    outputX=(c2-c1)/(m1-m2),
    outputY=m1*outputX+c1
  )
	[outputX,outputY,r];

function RailCustomiser(rp,o1=0,o2,mode=0,minR=0,a1,a2)= 
  /*This function takes a series of radii points and plots points to run along side at a constanit distance, think of it as offset but for line instead of a polygon
  rp=radii points, o1&o2=offset 1&2,minR=min radius, a1&2=angle 1&2
  mode=1 - include endpoints a1&2 are relative to the angle of the last two points and equal 90deg if not defined
  mode=2 - endpoints not included
  mode=3 - include endpoints a1&2 are absolute from the x axis and are 0 if not defined
  negative radiuses only allowed for the first and last radii points
  
  As it stands this function could probably be tidied a lot, but it works, I'll tidy later*/
  let(
    o2undef=o2==undef?1:0,
    o2=o2undef==1?0:o2,
    CWorCCW1=sign(o1)*CWorCCW(rp),
    CWorCCW2=sign(o2)*CWorCCW(rp),
    o1=abs(o1),
    o2b=abs(o2),
    Lrp3=len(rp)-3,
    Lrp=len(rp),
    a1=mode==0&&a1==undef?
      getAngle(rp[0],rp[1])+90:
      mode==2&&a1==undef?
      0:
      mode==0?
      getAngle(rp[0],rp[1])+a1:
      a1,
    a2=mode==0&&a2==undef?
            getAngle(rp[Lrp-1],rp[Lrp-2])+90:
        mode==2&&a2==undef?
            0:
        mode==0?
            getAngle(rp[Lrp-1],rp[Lrp-2])+a2:
            a2,
    OffLn1=[for(i=[0:Lrp3]) o1==0?rp[i+1]:parallelFollow([rp[i],rp[i+1],rp[i+2]],o1,minR,mode=CWorCCW1)],
    OffLn2=[for(i=[0:Lrp3]) o2==0?rp[i+1]:parallelFollow([rp[i],rp[i+1],rp[i+2]],o2b,minR,mode=CWorCCW2)],  
    Rp1=abs(rp[0].z),
    Rp2=abs(rp[Lrp-1].z),
    endP1a=findPoint(getAngle(rp[0],rp[1]),         OffLn1[0],              a1,rp[0],     Rp1),
    endP1b=findPoint(getAngle(rp[Lrp-1],rp[Lrp-2]), OffLn1[len(OffLn1)-1],  a2,rp[Lrp-1], Rp2),
    endP2a=findPoint(getAngle(rp[0],rp[1]),         OffLn2[0],              a1,rp[0],     Rp1),
    endP2b=findPoint(getAngle(rp[Lrp-1],rp[Lrp-2]), OffLn2[len(OffLn1)-1],  a2,rp[Lrp-1], Rp2),
    absEnda=getAngle(endP1a,endP2a),
    absEndb=getAngle(endP1b,endP2b),
    negRP1a=[cos(absEnda)*rp[0].z*10+endP1a.x,        sin(absEnda)*rp[0].z*10+endP1a.y,       0.0],
    negRP2a=[cos(absEnda)*-rp[0].z*10+endP2a.x,       sin(absEnda)*-rp[0].z*10+endP2a.y,      0.0],
    negRP1b=[cos(absEndb)*rp[Lrp-1].z*10+endP1b.x,    sin(absEndb)*rp[Lrp-1].z*10+endP1b.y,   0.0],
    negRP2b=[cos(absEndb)*-rp[Lrp-1].z*10+endP2b.x,   sin(absEndb)*-rp[Lrp-1].z*10+endP2b.y,  0.0],
    OffLn1b=(mode==0||mode==2)&&rp[0].z<0&&rp[Lrp-1].z<0?
        concat([negRP1a],[endP1a],OffLn1,[endP1b],[negRP1b])
      :(mode==0||mode==2)&&rp[0].z<0?
        concat([negRP1a],[endP1a],OffLn1,[endP1b])
      :(mode==0||mode==2)&&rp[Lrp-1].z<0?
        concat([endP1a],OffLn1,[endP1b],[negRP1b])
      :mode==0||mode==2?
        concat([endP1a],OffLn1,[endP1b])
      :
        OffLn1,
    OffLn2b=(mode==0||mode==2)&&rp[0].z<0&&rp[Lrp-1].z<0?
        concat([negRP2a],[endP2a],OffLn2,[endP2b],[negRP2b])
      :(mode==0||mode==2)&&rp[0].z<0?
        concat([negRP2a],[endP2a],OffLn2,[endP2b])
      :(mode==0||mode==2)&&rp[Lrp-1].z<0?
        concat([endP2a],OffLn2,[endP2b],[negRP2b])
      :mode==0||mode==2?
        concat([endP2a],OffLn2,[endP2b])
      :
        OffLn2
    )//end of let()
  o2undef==1?OffLn1b:concat(OffLn2b,revList(OffLn1b));
    
function revList(list)=//reverse list
  let(Llist=len(list)-1)
  [for(i=[0:Llist]) list[Llist-i]];

function CWorCCW(p)=
	let(
    Lp=len(p),
	  e=[for(i=[0:Lp-1]) 
      (p[wrap(i+0,Lp)].x-p[wrap(i+1,Lp)].x)*(p[wrap(i+0,Lp)].y+p[wrap(i+1,Lp)].y)
    ]
  )  
  sign(sum(e));

function CentreN2PointsArc(p1,p2,cen,mode=0,fn)=
  /* This function plots an arc from p1 to p2 with fn increments using the cen as the centre of the arc.
  the mode determines how the arc is plotted
  mode==0, shortest arc possible 
  mode==1, longest arc possible
  mode==2, plotted clockwise
  mode==3, plotted counter clockwise
  */
	let(
    CWorCCW=CWorCCW([cen,p1,p2]),//determine the direction of rotation
    //determine the arc angle depending on the mode
    p1p2Angle=cosineRuleAngle(p2,cen,p1),
    arcAngle=
      mode==0?p1p2Angle:
      mode==1?p1p2Angle-360:
      mode==2&&CWorCCW==-1?p1p2Angle:
      mode==2&&CWorCCW== 1?p1p2Angle-360:
      mode==3&&CWorCCW== 1?p1p2Angle:
      mode==3&&CWorCCW==-1?p1p2Angle-360:
      cosineRuleAngle(p2,cen,p1)
    ,
    r=pointDist(p1,cen),//determine the radius
	  p1Angle=getAngle(cen,p1) //angle of line 1
  )
  [for(i=[0:fn]) [cos(p1Angle+(arcAngle/fn)*i*CWorCCW)*r+cen[0],sin(p1Angle+(arcAngle/fn)*i*CWorCCW)*r+cen[1]]];

function moveRadiiPoints(rp,tran=[0,0],rot=0)=
	[for(i=rp) 
		let(
      a=getAngle([0,0],[i.x,i.y]),//get the angle of the this point
		  h=pointDist([0,0],[i.x,i.y]) //get the hypotenuse/radius
    )
		[h*cos(a+rot)+tran.x,h*sin(a+rot)+tran.y,i.z]//calculate the point's new position
	];

module round2d(OR=3,IR=1){
  offset(OR){
    offset(-IR-OR){
      offset(IR){
        children();
      }
    }
  }
}

module shell2d(o1,OR=0,IR=0,o2=0){
	difference(){
		round2d(OR,IR){
      offset(max(o1,o2)){
        children(0);//original 1st child forms the outside of the shell
      }
    }
		round2d(IR,OR){
      difference(){//round the inside cutout
        offset(min(o1,o2)){
          children(0);//shrink the 1st child to form the inside of the shell 
        }
        if($children>1){
          for(i=[1:$children-1]){
            children(i);//second child and onwards is used to add material to inside of the shell
          }
        }
      }
		}
	}
}

module internalSq(size,r,center=0){
    tran=center==1?[0,0]:size/2;
    translate(tran){
      square(size,true);
      offs=sin(45)*r;
      for(i=[-1,1],j=[-1,1]){
        translate([(size.x/2-offs)*i,(size.y/2-offs)*j])circle(r);
      }
    }
}

module r_extrude(ln,r1=0,r2=0,fn=30){
  n1=sign(r1);n2=sign(r2);
  r1=abs(r1);r2=abs(r2);
  translate([0,0,r1]){
    linear_extrude(ln-r1-r2){
      children();
    }
  }
  for(i=[0:1/fn:1]){
    translate([0,0,i*r1]){
      linear_extrude(r1/fn){
        offset(n1*sqrt(sq(r1)-sq(r1-i*r1))-n1*r1){
          children();
        }
      }
    }
    translate([0,0,ln-r2+i*r2]){
      linear_extrude(r2/fn){
        offset(n2*sqrt(sq(r2)-sq(i*r2))-n2*r2){
          children();
        }
      }
    }
  }
}

function mirrorPoints(b,rot=0,atten=[0,0])= //mirrors a list of points about Y, ignoring the first and last points and returning them in reverse order for use with polygon or polyRound
  let(
    a=moveRadiiPoints(b,[0,0],-rot),
    temp3=[for(i=[0+atten[0]:len(a)-1-atten[1]])
      [a[i][0],-a[i][1],a[i][2]]
    ],
    temp=moveRadiiPoints(temp3,[0,0],rot),
    temp2=revList(temp3)
  )    
  concat(b,temp2);

function processRadiiPoints(rp)=
  [for(i=[0:len(rp)-1]) 
    processRadiiPoints2(rp,i)
  ];

function processRadiiPoints2(list,end=0,idx=0,result=0)=
  idx>=end+1?result:
  processRadiiPoints2(list,end,idx+1,relationalRadiiPoints(result,list[idx]));

function cosineRuleBside(a,c,C)=c*cos(C)-sqrt(sq(a)+sq(c)+sq(cos(C))-sq(c));

function absArelR(po,pn)=
  let(
    th2=atan(po[1]/po[0]),
    r2=sqrt(sq(po[0])+sq(po[1])),
    r3=cosineRuleBside(r2,pn[1],th2-pn[0])
  )
  [cos(pn[0])*r3,sin(pn[0])*r3,pn[2]];

function relationalRadiiPoints(po,pi)=
  let(
    p0=pi[0],
    p1=pi[1],
    p2=pi[2],
    pv0=pi[3][0],
    pv1=pi[3][1],
    pt0=pi[3][2],
    pt1=pi[3][3],
    pn=
      (pv0=="y"&&pv1=="x")||(pv0=="r"&&pv1=="a")||(pv0=="y"&&pv1=="a")||(pv0=="x"&&pv1=="a")||(pv0=="y"&&pv1=="r")||(pv0=="x"&&pv1=="r")?
        [p1,p0,p2,concat(pv1,pv0,pt1,pt0)]:
        [p0,p1,p2,concat(pv0,pv1,pt0,pt1)],
    n0=pn[0],
    n1=pn[1],
    n2=pn[2],
    nv0=pn[3][0],
    nv1=pn[3][1],
    nt0=pn[3][2],
    nt1=pn[3][3],
    temp=
      pn[0]=="l"?
        [po[0],pn[1],pn[2]]
      :pn[1]=="l"?
        [pn[0],po[1],pn[2]]
      :nv0==undef?
        [pn[0],pn[1],pn[2]]//abs x, abs y as default when undefined
      :nv0=="a"?
        nv1=="r"?
          nt0=="a"?
            nt1=="a"||nt1==undef?
              [cos(n0)*n1,sin(n0)*n1,n2]//abs angle, abs radius
            :absArelR(po,pn)//abs angle rel radius
          :nt1=="r"||nt1==undef?
            [po[0]+cos(pn[0])*pn[1],po[1]+sin(pn[0])*pn[1],pn[2]]//rel angle, rel radius 
          :[pn[0],pn[1],pn[2]]//rel angle, abs radius
        :nv1=="x"?
          nt0=="a"?
            nt1=="a"||nt1==undef?
              [pn[1],pn[1]*tan(pn[0]),pn[2]]//abs angle, abs x
            :[po[0]+pn[1],(po[0]+pn[1])*tan(pn[0]),pn[2]]//abs angle rel x
            :nt1=="r"||nt1==undef?
              [po[0]+pn[1],po[1]+pn[1]*tan(pn[0]),pn[2]]//rel angle, rel x 
            :[pn[1],po[1]+(pn[1]-po[0])*tan(pn[0]),pn[2]]//rel angle, abs x
          :nt0=="a"?
            nt1=="a"||nt1==undef?
              [pn[1]/tan(pn[0]),pn[1],pn[2]]//abs angle, abs y
            :[(po[1]+pn[1])/tan(pn[0]),po[1]+pn[1],pn[2]]//abs angle rel y
          :nt1=="r"||nt1==undef?
            [po[0]+(pn[1]-po[0])/tan(90-pn[0]),po[1]+pn[1],pn[2]]//rel angle, rel y 
          :[po[0]+(pn[1]-po[1])/tan(pn[0]),pn[1],pn[2]]//rel angle, abs y
      :nv0=="r"?
        nv1=="x"?
          nt0=="a"?
            nt1=="a"||nt1==undef?
              [pn[1],sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1])),pn[2]]//abs radius, abs x
            :[po[0]+pn[1],sign(pn[0])*sqrt(sq(pn[0])-sq(po[0]+pn[1])),pn[2]]//abs radius rel x
          :nt1=="r"||nt1==undef?
            [po[0]+pn[1],po[1]+sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1])),pn[2]]//rel radius, rel x 
          :[pn[1],po[1]+sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1]-po[0])),pn[2]]//rel radius, abs x
        :nt0=="a"?
          nt1=="a"||nt1==undef?
            [sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1])),pn[1],pn[2]]//abs radius, abs y
          :[sign(pn[0])*sqrt(sq(pn[0])-sq(po[1]+pn[1])),po[1]+pn[1],pn[2]]//abs radius rel y
        :nt1=="r"||nt1==undef?
          [po[0]+sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1])),po[1]+pn[1],pn[2]]//rel radius, rel y 
        :[po[0]+sign(pn[0])*sqrt(sq(pn[0])-sq(pn[1]-po[1])),pn[1],pn[2]]//rel radius, abs y
      :nt0=="a"?
        nt1=="a"||nt1==undef?
          [pn[0],pn[1],pn[2]]//abs x, abs y
        :[pn[0],po[1]+pn[1],pn[2]]//abs x rel y
      :nt1=="r"||nt1==undef?
        [po[0]+pn[0],po[1]+pn[1],pn[2]]//rel x, rel y 
      :[po[0]+pn[0],pn[1],pn[2]]//rel x, abs y
  )
  temp;

function invtan(run,rise)=
  let(a=abs(atan(rise/run)))
  rise==0&&run>0?
    0:rise>0&&run>0?
    a:rise>0&&run==0?
    90:rise>0&&run<0?
    180-a:rise==0&&run<0?
    180:rise<0&&run<0?
    a+180:rise<0&&run==0?
    270:rise<0&&run>0?
    360-a:"error";

function cosineRuleAngle(p1,p2,p3)=
  let(
    p12=abs(pointDist(p1,p2)),
    p13=abs(pointDist(p1,p3)),
    p23=abs(pointDist(p2,p3))
  )
  acos((sq(p23)+sq(p12)-sq(p13))/(2*p23*p12));

function sum(list, idx = 0, result = 0) = 
	idx >= len(list) ? result : sum(list, idx + 1, result + list[idx]);

function sq(x)=x*x;
function getGradient(p1,p2)=(p2.y-p1.y)/(p2.x-p1.x);
function getAngle(p1,p2)=p1==p2?0:invtan(p2[0]-p1[0],p2[1]-p1[1]);
function getMidpoint(p1,p2)=[(p1[0]+p2[0])/2,(p1[1]+p2[1])/2]; //returns the midpoint of two points
function pointDist(p1,p2)=sqrt(abs(sq(p1[0]-p2[0])+sq(p1[1]-p2[1]))); //returns the distance between two points
function isColinear(p1,p2,p3)=getGradient(p1,p2)==getGradient(p2,p3)?1:0;//return 1 if 3 points are colinear
module polyline(p) {
  for(i=[0:max(0,len(p)-1)]){
    line(p[i],p[wrap(i+1,len(p) )]);
  }
} // polyline plotter
module line(p1, p2 ,width=0.3) { // single line plotter
  hull() {
    translate(p1){
      circle(width);
    }
    translate(p2){
      circle(width);
    }
  }
}

function getpoints(p)=[for(i=[0:len(p)-1])[p[i].x,p[i].y]];// gets [x,y]list of[x,y,r]list
function wrap(x,x_max=1,x_min=0) = (((x - x_min) % (x_max - x_min)) + (x_max - x_min)) % (x_max - x_min) + x_min; // wraps numbers inside boundaries
function rnd(a = 1, b = 0, s = []) = 
  s == [] ? 
    (rands(min(a, b), max(   a, b), 1)[0]):(rands(min(a, b), max(a, b), 1, s)[0]); // nice rands wrapper 



//////////////// HEX PATTERN

// Customizable hex pattern
// Created by Kjell Kernen
// Date 22.9.2014

module hex(x,y, hex_radius, hex_border_width, height,render=true)
{
    if (render) {
        difference()
        {
            translate([x,y,-height/20]) 
                cylinder(r=(hex_radius+hex_border_width/20), h=height/10, $fn=6);	
            translate([x,y,-height/20]) 
                cylinder(r=(hex_radius-hex_border_width/20), h=height/10, $fn=6);
        }
    }
}

// Hex mesh and border parameters:
//   width -- distance along the X axis, in mm, range 10-100
//   length -- distance along the Y axis, in mm, range 10-100
//   hex_radius -- radius of the hex, in mm, range 1-20
//   height -- distance along the Z axis, in 0.1 mm, range 2-200
//   border_width -- width of the solid border arond the hex pattern, in 0.1 mm, range 2-100
//   hex_border_width -- width of the border around each hex, in 0.1mm, range 2-50

module hexwall(width, length, height, border_width=20, hex_radius=5, hex_border_width=30) {
    xborder=(border_width/10<width)?width-border_width/10:0;
    yborder=(border_width/10<length)?length-border_width/10:0;

    x=sqrt(3/4*hex_radius*hex_radius);
    ystep=2*x;
    xstep=3*hex_radius/2;

    translate([width/2,length/2,0]){
        //Pattern
        intersection()
        {
            for (xi=[0:xstep:width])
                for(yi=[0:ystep:length])
                    hex(xi-width/2,((((xi/xstep)%2)==0)?0:ystep/2)+yi-length/2, hex_radius, hex_border_width, height);
            translate([-width/2, -length/2, -height/20]) 
                cube([width,length,height/10]);
        }

        // Frame
        difference()
        {
            translate([-width/2, -length/2, -height/20]) 
                cube([width,length,height/10]);
            translate([-xborder/2, -yborder/2, -(height/20+0.1)]) 
                cube([xborder,yborder,height/10+0.2]); 
        }
    }
}
