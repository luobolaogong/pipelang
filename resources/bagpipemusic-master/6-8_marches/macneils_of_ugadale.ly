\score {

  {
    \bagpipeKey
    \time 6/8

    % Part 1

    \repeat volta 2 {
      \partial 8 A8
      c8. d16 \gre b8 \grg a4 \taor a8
      \grg c16 e8. \gra e8 \dble e8. c16 \grd a8
      \grg f8. e16 c8 \grg e8. f16 A8
      \grg A8. e16 \grg c8 \slurb b4 A8
      \break
      c8. d16 \gre b8 \grg a4 \taor a8
      \grg c16 e8. \gra e8 \dble e8. c16 \grd a8
      \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
      \gre a4. \wbirl a4
    }
    \break

    % Part 2

    \repeat volta 2 {
      e8
      A8. g16 \grA f8 \dble e4 A8
      e8. f16 \grg e8 \dble e8. \grg c16 \grd a8
      A8. g16 \grA f8 \dble e4 A8
      \grg A8. e16 \grg c8 \slurb b4
    }
    \alternative {
      {
        e8
        \break
        A8. g16 \grA f8 \dble e4 A8
        e8. f16 \grg e8 \dble e8. \grg c16 \grd a8
        \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
        \gre a4. \wbirl a4
        \break
      }
      {
        A8
        c8. d16 \gre a8 \grg a4 \taor a8
        \grg c16 e8. \gra e8 \dble e8. c16 \grd a8
        \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
        \gre a4. \wbirl a4
      }
    }
    \break

    % Part 3

    \repeat volta 2 {
      A8
      \hdblc c4. \grG a4.
      \grg c16 e8. \gra e8 \dble e8. c16 \grd a8
      \grg f4. \thrwd d4 A8
      \grg A8. e16 \grg c8 \slurb b4 A8
      \break
      \hdblc c4. \grG a4.
      \grg c16 e8. \gra e8 \dble e8. c16 \grd a8
      \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
      \gre a4. \wbirl a4
    }
    \break

    % Part 4

    \repeat volta 2 {
      e8
      \grg f4 \dblA A8 \thrwd d4 \dblA A8
      e8. f16 \grg e8 \dble e8. c16 \grG a8
      \grg f4 \dblA A8 \thrwd d4 \dblA A8
      \grg A8. e16 \grg c8 \slurb b4
    }
    \alternative {
      {
        e8
        \break
        \grg f4 \dblA A8 \thrwd d4 \dblA A8
        e8. f16 \grg e8 \dble e8. c16 \grG a8
        \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
        \gre a4. \wbirl a4
        \break
      }
      {
        A8
        c16 d8. \gre b8 \grg e8. f16 \grg c8
        A8. g16 \grA f8 \dble e4 A8
        \grg c16 d8. \gre b8 \grg e8. f16 \grg c8
        \gre a4. \wbirl a4
      }
    }
    \bar "|."
  }

  \header {
    meter = "March"
    title = "The MacNeils of Ugadale"
    composer = "P/M J. M. MacKenzie"
    arranger = "Arr. MPD"
    loc = "55.4232349,-5.7345576"
    map = "https://goo.gl/maps/tYRATGa6nHJ2"
  }

}
