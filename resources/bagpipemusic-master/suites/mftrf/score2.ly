\layout {
  \context {
    \Score
    \revert NonMusicalPaperColumn #'line-break-permission
    \consists "Bar_number_engraver"
  }
}

\include "suites/mftrf/music2.ly"

\score {

  \new StaffGroup <<
    \new Staff \menuetTwoA
    \new Staff \menuetTwoB
  >>

  \header {
    meter = "Menuet [2]"
    title = "Music for the Royal Fireworks"
    composer = "Georg Friedrich Händel"
    arranger = "Arr. MPD"
  }
}
