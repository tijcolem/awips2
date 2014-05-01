C MEMBER SFPEBD
C-----------------------------------------------------------------------
C
      BLOCK DATA SFPEBD
C
C  FOURIER SERIES COEFFICIENTS FOR STATION PE PARAMETERS
C
      COMMON /SFPEX/ A0(131),A1(131),A2(131),A3(131),B1(131),B2(131)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68                RCSKW1,RCSKW2
      COMMON / RCSSFPEBD        / RCSKW1,RCSKW2
      DATA                        RCSKW1,RCSKW2 /                      '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/block/RCS/sfpebd.f,v $
     . $',                                                             '
     .$Id: sfpebd.f,v 1.1 1995/09/17 18:41:25 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA A0/622.22,621.03,619.83,618.62,617.40,616.17,
     1   614.93,613.69,612.45,611.21,609.97,608.71,607.46,
     1   606.20,604.95,603.69,602.41,601.13,599.85,598.57,597.29,595.99,
     2   594.70,593.40,592.11,590.81,589.49,588.17,586.85,585.53,584.21,
     3   582.87,581.54,580.20,578.87,577.53,576.17,574.81,573.45,572.09,
     4   570.73,569.35,567.98,566.60,565.23,563.85,562.45,561.05,559.65,
     5   558.25,556.85,555.43,554.02,552.60,551.19,549.77,548.33,546.89,
     6   545.45,544.01,542.57,541.12,539.66,538.21,536.75,535.30,533.82,
     7   532.34,530.86,529.38,527.90,526.41,525.92,523.42,521.93,520.44,
     8   518.92,517.40,515.89,514.37,512.85,511.32,509.79,508.25,506.72,
     9   505.19,503.63,502.07,500.52,498.96,497.40,495.82,404.25,492.67,
     1   491.10,489.52,487.92,486.32,484.73,483.13,481.53,479.91,478.30,
     2   476.69,475.07,473.45,471.81,470.18,468.54,466.91,465.27,463.61,
     3   461.96,460.30,458.65,456.99,455.31,453.64,451.96,450.29,448.61,
     4   446.92,445.22,443.53,441.83,440.14,438.42,436.70,434.98,433.27,
     5   431.55/
C
      DATA A1/-140.87,-142.27,-143.67,-145.06,-146.45,
     1-147.83,-149.21,-150.58,-151.96,-153.33,-154.71,-156.08,
     1-157.44,-158.81,-160.18,-161.55,-162.91,-164.27,-165.62,-166.97,
     2-168.33,-169.67,-171.02,-172.36,-173.71,-175.05,-176.38,-177.72,
     3-179.05,-180.39,-181.72,-183.04,-184.37,-185.69,-187.02,-188.34,
     4-189.65,-190.97,-192.28,-193.60,-194.91,-196.21,-197.51,-198.82,
     5-200.12,-201.42,-202.59,-203.77,-204.94,-206.12,-207.29,-208.69,
     6-210.09,-211.49,-212.89,-214.29,-215.56,-216.83,-218.11,-219.38,
     7-220.65,-221.91,-223.17,-224.44,-225.70,-226.96,-228.21,-229.46,
     8-230.72,-231.97,-233.22,-234.46,-235.70,-236.95,-238.19,-239.43,
     9-240.66,-241.89,-243.13,-244.36,-245.59,-246.81,-248.03,-249.25,
     1-250.47,-251.69,-252.90,-254.11,-255.32,-256.53,-257.74,-258.94,
     2-260.14,-261.34,-262.54,-263.74,-264.93,-266.12,-267.32,-268.51,
     3-269.70,-270.88,-272.06,-273.24,-274.42,-275.60,-276.77,-277.94,
     4-279.11,-280.78,-281.45,-282.61,-283.77,-284.93,-286.09,-287.25,
     5-288.40,-289.55,-290.69,-291.84,-292.99,-293.56,-294.70,-295.84,
     6-296.97,-298.68,-299.81,-300.94,-302.06,-303.19,-304.32/
C
      DATA A2/-26.57,-26.73,-26.87,-26.99,-27.09,
     1-27.17,-27.23,-27.30,-27.36,-27.43,-27.49,-27.53,-27.57,
     1-27.61,-27.65,-27.69,-27.70,-27.72,-27.74,-27.76,-27.78,-27.77,
     2-27.76,-27.76,-27.75,-27.74,-27.71,-27.67,-27.64,-27.60,-27.57,
     3-27.51,-27.46,-27.40,-27.35,-27.29,-27.21,-27.13,-27.05,-26.97,
     4-26.89,-26.79,-26.68,-26.58,-26.47,-26.37,-26.24,-26.11,-25.98,
     5-25.85,-25.72,-25.57,-25.42,-25.26,-25.11,-24.96,-24.78,-24.60,
     6-24.42,-24.24,-24.07,-23.81,-23.67,-23.47,-23.27,-23.07,-22.85,
     8-20.43,-20.15,-19.88,-19.60,-19.33,-19.03,-18.73,-18.43,-18.13,
     7-22.62,-22.40,-22.17,-21.95,-21.70,-21.45,-21.20,-20.95,-20.70,
     9-17.83,-17.51,-17.19,-16.86,-16.54,-16.22,-15.87,-15.53,-15.18,
     1-14.84,-14.49,-14.12,-13.75,-13.37,-13.00,-12.63,-12.26,-11.89,
     2-11.51,-11.14,-10.65,-10.23,- 9.60,- 9.39,- 8.97,- 8.55,- 8.11,
     3- 7.66,- 7.22,- 6.77,- 6.33,- 5.86,- 5.39,- 4.92,- 4.45,- 3.98,
     4- 3.49,- 2.99,- 2.50,- 2.00,- 1.51,- 1.43,- 1.34,- 1.25,- 1.17,
     5- 1.08/
C
      DATA A3/-3.37,-3.33,-3.29,-3.25,-3.21,
     1-3.17,-3.13,-3.09,-3.05,-3.01,-2.97,-2.93,-2.89,-2.86,
     1-2.82,-2.78,-2.74,-2.71,-2.67,-2.64,-2.60,-2.57,-2.53,-2.50,-2.46,
     2-2.43,-2.40,-2.37,-2.34,-2.31,-2.28,-2.25,-2.22,-2.20,-2.17,-2.14,
     3-2.12,-2.09,-2.07,-2.04,-2.02,-2.00,-1.98,-1.95,-1.93,-1.91,-1.89,
     4-1.87,-1.85,-1.83,-1.81,-1.79,-1.77,-1.75,-1.73,-1.72,-1.70,-1.69,
     5-1.67,-1.66,-1.64,-1.63,-1.62,-1.61,-1.60,-1.59,-1.58,-1.57,-1.57,
     6-1.56,-1.55,-1.54,-1.54,-1.53,-1.53,-1.52,-1.52,-1.52,-1.51,-1.51,
     7-1.51,-1.51,-1.51,-1.51,-1.51,-1.51,-1.51,-1.51,-1.52,-1.52,-1.52,
     8-1.52,-1.53,-1.53,-1.54,-1.54,-1.55,-1.55,-1.56,-1.56,-1.57,-1.58,
     9-1.59,-1.61,-1.62,-1.63,-1.64,-1.66,-1.68,-1.69,-1.71,-1.73,-1.75,
     1-1.76,-1.78,-1.80,-1.82,-1.84,-1.86,-1.88,-1.90,-1.92,-1.94,-1.97,
     2-1.99,-2.01,-2.03,-2.06,-2.08,-2.11,-2.13/
C
      DATA B1/11.58,11.64,11.70,11.75,11.80,
     111.84,11.88,11.92,11.96,12.00,12.04,12.08,12.11,12.15,
     112.18,12.22,12.25,12.28,12.32,12.35,12.38,12.41,12.44,12.47,12.50,
     212.53,12.56,12.59,12.61,12.64,12.67,12.70,12.72,12.75,12.77,12.80,
     312.82,12.85,12.87,12.90,12.92,12.94,12.96,12.99,13.01,13.03,13.05,
     413.07,13.09,13.11,13.13,13.15,13.17,13.18,13.20,13.22,13.24,13.25,
     513.27,13.28,13.30,13.31,13.32,13.34,13.35,13.36,13.37,13.38,13.38,
     613.39,13.40,13.40,13.41,13.41,13.42,13.42,13.42,13.42,13.42,13.42,
     713.42,13.42,13.42,13.41,13.41,13.41,13.41,13.40,13.40,13.39,13.39,
     813.38,13.38,13.37,13.37,13.36,13.35,13.34,13.34,13.33,13.32,13.31,
     913.30,13.29,13.28,13.27,13.26,13.25,13.23,13.22,13.21,13.20,13.18,
     113.17,13.15,13.14,13.13,13.11,13.10,13.08,13.07,13.06,13.04,13.03,
     213.01,13.00,12.98,12.97,12.95,12.94,12.92/
C
      DATA B2/2.87,2.68,2.50,2.33,2.17,
     12.02,1.88,1.73,1.59,1.44,1.30,1.17,1.04,0.90,0.77,0.64,
     10.52,0.39,0.24,0.14,0.02,-0.10,-0.21,-0.33,-0.44,-0.56,-0.67,
     2-0.78,-0.88,-0.99,-1.10,-1.20,-1.30,-1.40,-1.50,-1.60,-1.69,-1.78,
     3-1.87,-1.96,-2.05,-2.13,-2.21,-2.29,-2.37,-2.45,-2.52,-2.59,-2.66,
     4-2.73,-2.80,-2.86,-2.92,-2.98,-3.04,-3.10,-3.15,-3.20,-3.25,-3.30,
     5-3.35,-3.40,-3.44,-3.49,-3.53,-3.58,-3.62,-3.66,-3.69,-3.73,-3.77,
     6-3.80,-3.83,-3.86,-3.89,-3.92,-3.94,-3.96,-3.99,-4.01,-4.03,-4.04,
     7-4.06,-4.07,-4.09,-4.10,-4.11,-4.11,-4.12,-4.12,-4.13,-4.13,-4.13,
     8-4.12,-4.12,-4.12,-4.11,-4.10,-4.09,-4.08,-4.07,-4.05,-4.03,-4.02,
     9-4.00,-3.98,-3.95,-3.93,-3.90,-3.88,-3.85,-3.82,-3.78,-3.75,-3.71,
     1-3.68,-3.64,-3.60,-3.55,-3.51,-3.47,-3.44,-3.40,-3.37,-3.33,-3.30,
     2-3.27,-3.25,-3.22,-3.20,-3.17/
C
      END
