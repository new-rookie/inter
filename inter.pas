program starflight;

uses graphABC;

const
  G = 6.67e-11; // gravitational constant
  c = 3e8; 
  year = 365.242 * 24 * 3600;
  light_year = year * c;
  Msun = 1.9891e30;
  ae = 1.5e11; // astronomical unit
  s1 = 1.56e18; // scale m / pixel
  s2 = 1.5e18; // scale m / pixel
  s3 = 2e12; // scale m / pixel
  N = 4;// count from 0
  t_flight = 22 * 1e6 * year;

var
  collision: boolean; 
  sn: integer; // счётчик шагов
  r, r3, t, dt, ax, ay, r_star_rocket, x_rocket_star, y_rocket_star, dvx, dvy, epsilon: real; 
  m, x, y, vx, vy, Rb: array [0..N] of real;

begin
    // Еntry conditions
    //Galaxy center
  Rb[0] := 3.09e15; // radius of the galaxy center
  m[0] := Msun * 1.1e11; // mass of the galaxy center
  x[0] := 0;
  y[0] := 0;
  vx[0] := 0;
  vy[0] := 0;
  
    //Sun
  Rb[1] := 6.9551e8; // radius of the sun
  m[1] := Msun; // solar mass
  x[1] := 2.77e4 * light_year; // distance from the sun to the galaxy center 
  y[1] := 0;
  vx[1] := 0;
  vy[1] := sqrt(G * m[0] / x[1]);
  
    //Random Star
  Rb[2] := 10 * Rb[1]; // radius of the star
  m[2] := 4 * Msun; // mass of the star
  x[2] := 1.3e4 * light_year; // distance from the star to the galaxy center 
  y[2] := 0;
  vx[2] := 0;
  vy[2] := 0.7 * sqrt(G * m[0] / x[2]);
  
    //Random Star 2
  Rb[3] := 7 * Rb[1]; // radius of the star
  m[3] := 4 * Msun; // mass of the star
  x[3] := 2e4 * light_year; // distance from the star to the galaxy center 
  y[3] := 0;
  vx[3] := 0;
  vy[3] := 0.9 * sqrt(G * m[0] / x[3]);
  
    //Rocket
  Rb[4] := 1e2; // radius of the rocket
  m[4] := 1e10; // mass of rocket
  x[4] := x[1] + ae;  // distance from the rocket to the galaxy center
  y[4] := y[1];
  //v_out_rocket := sqrt(2 * G * m[1] / ae) * 3.5;  
  vx[4] := vx[1];
  vy[4] := vy[1] + 3e4;
  
  t := 0;
  sn := 0;
  dt := 10 * year;
  r_star_rocket := 9e100;
  epsilon := 1e-3;
  collision := false;
  MaximizeWindow;
  line(450, 0, 450, 450);        
  line(0, 450, 1400, 450);
  
    // solving equations of motion
  repeat
    for var i := 0 to N do // movement of the i body
    begin
      x[i] += vx[i] * dt; // new coordinate of the i body
      y[i] += vy[i] * dt;
      ax := 0; // resetting the acceleration amount
      ay := 0;
      for var j := 0 to N do // interaction with j bodies
      begin
        if (j <> i) then // excluding the body's interaction with itself
        begin
          r := sqrt(sqr(x[j] - x[i]) + sqr(y[j] - y[i])); // distance between the centers of the i - th and j - th body
          r3 := r * r * r; // distance in cube
          ax += G * m[j] / r3 * (x[j] - x[i]); // gravitational acceleration   
          ay += G * m[j] / r3 * (y[j] - y[i]); 
          //spacecraft control
          if ((sn mod 100) = 0) and (i = 4) then
          begin
            x_rocket_star := x[3] - x[4];
            y_rocket_star := y[3] - y[4];
            dvx := epsilon * (x_rocket_star / t_flight + vx[3] - vx[4]);
            dvy := epsilon * (y_rocket_star / t_flight + vy[3] - vy[4]);
          end;
        end;
      end;
      if (i = 4) then
      begin
        vx[i] += ax * dt + dvx; // new speed of the i - th body
        vy[i] += ay * dt + dvy;
      end
      else
      begin
        vx[i] += ax * dt; // new speed of the i - th body
        vy[i] += ay * dt;
      end;
      if (sn mod 1000000) = 0 then // print flight time
      begin
        TextOut(10, 50, t / year / 1e6);
      end;
      r_star_rocket := sqrt(sqr(x[4] - x[3]) + sqr(y[4] - y[3]));
      if r_star_rocket <= 1.5e14 then dt := 0.1 * year;
      //graphics
      if (sn mod 1000) = 0 then // adjusting the steps through which the graph is drawn
      begin
        if (r_star_rocket < 5e13) then collision := true;
        if collision then 
        begin
          TextOut(50, 50, 'Success');
          exit;
        end;            
        // the trajectory of the bodies
        case i of
          0: Pen.Color := clDarkBlue; // galaxy center
          1: Pen.Color := clRed; // sun
          2: Pen.Color := clCornflowerBlue;//random star 1  
          3: Pen.Color := clDarkOrange; // random star 2
          4: Pen.Color := clPurple; //rocket
        end; 
        circle(200 + round(x[i] / s1), 200 + round(y[i] / s1), 1); // all
        if (i = 1) or (i = 3) or (i = 4) then // star, sun, rocket
          circle(750 + round((x[i] - x[1]) / s2), 175 + round((y[i] - y[1]) / s2), 1);
        if (i = 3) or (i = 4) then circle(200 + round((x[i] - x[3]) / s3), 550 + round((y[i] - y[3]) / s3), 1); // star, rocket
      end;
    end;
    t += dt; // шаг по времени
    sn += 1;
  until t > year * 1e10;
end.       
