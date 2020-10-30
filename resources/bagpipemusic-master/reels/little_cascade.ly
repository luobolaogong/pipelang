\score {

  {
    \bagpipeKey
    \reelTime

    % Part 1

    \repeat volta 2 {
      \grg b8 e \gra e g \grA g e \grg b g
      \grA g[ f \dble e b] \grA g b \grg e g
      \grA b e \gra e g \grA g e \grg b g
    }
    \alternative {
      {
        \tdblf f d \gre a d \grg f A g f
      }
      {
        \grA f A g f \dblf f4 \hslure e8
      }
    }
    \break

    % Part 2

    \repeat volta 2 {
      g8
      \tdblf f b \grA g f \grg e g \grA b g
      \tdblf f b A g \grA g4 \hslurf f8 g
      \tdblf f b \grA g f \grg e g \grA b g
      \grA f A g f \dblf f4 e8
    }
    \break

    % Part 3

    \repeat volta 2 {
      g8
      \tdblG G4 \grd b8 e \grg b e \grA g e
      \dblg g4 \grA f8 g \grA e g \grA b e
    }
    \alternative {
      {
        \tdblG G4 \grd b8 e \grg b e \grA g e
        \dblf f d \gre a d \grg f A g f
      }
      {
        \tdblG G4 \grd b8 e \grA g e \grg b g
        \grA f A g f \dblf f4 \hslure e8
      }
    }
    \break

    % Part 4

    \repeat volta 2 {
      f8
      g \grA e f g \grA e f g \grA e
      f \grg d e f \grg d e f \grg d
      g \grA e f g \grA e f g \grA e
      \grg f A g \grA f \dblf f4 \hslure e8
    }
    \break

    % Part 5

    \repeat volta 2 {
      g8
      \grA b e \grA g f \grip e4 \grg f8 d
      \grg b e \grg d f \dble e d \grg b \grd a
      \grd b e \grA g f \grip e4 \grg f8 d
      \grg b e \grg d f \dblf f4 \hslure e8
    }
    \break

    % Part 6

    \repeat volta 2 {
      g8
      \grA G d \grg b e \grg d f \dble e4
      \grA g8 f g e \grg b e g A
    }
    \alternative {
      {
        G d \grg b e \grg d f \dble e4
        \barLength 7 8
        \grg b8 e \grg d f \dblf f4 \hslure e8
      }
      {
        \barLength 4 4
        \hdblg g f g e \grg f d \grg e d
        \grg b8 e \grg d f \dblf f4 \hslure e
      }
    }
    \bar "|."
  }

  \header {
    meter = "Reel"
    title = "The Little Cascade"
    composer = "P/M G. S. MacLennan"
  }

}
