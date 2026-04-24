(deffunction fuzzy-battery-poor (?score)
   (if (<= ?score 30) then
      (return 1.0))
   (if (and (> ?score 30) (< ?score 60)) then
      (return (/ (- 60 ?score) 30.0)))
   (return 0.0))

(deffunction fuzzy-battery-moderate (?score)
   (if (or (<= ?score 30) (>= ?score 80)) then
      (return 0.0))
   (if (and (> ?score 30) (< ?score 55)) then
      (return (/ (- ?score 30) 25.0)))
   (if (and (>= ?score 55) (< ?score 80)) then
      (return (/ (- 80 ?score) 25.0)))
   (return 0.0))

(deffunction fuzzy-battery-good (?score)
   (if (<= ?score 60) then
      (return 0.0))
   (if (and (> ?score 60) (< ?score 90)) then
      (return (/ (- ?score 60) 30.0)))
   (return 1.0))

(deffunction fuzzy-performance-poor (?score)
   (if (<= ?score 35) then
      (return 1.0))
   (if (and (> ?score 35) (< ?score 65)) then
      (return (/ (- 65 ?score) 30.0)))
   (return 0.0))

(deffunction fuzzy-performance-good (?score)
   (if (<= ?score 50) then
      (return 0.0))
   (if (and (> ?score 50) (< ?score 85)) then
      (return (/ (- ?score 50) 35.0)))
   (return 1.0))

(deffunction fuzzy-budget-low (?score)
   (if (<= ?score 35) then
      (return 1.0))
   (if (and (> ?score 35) (< ?score 60)) then
      (return (/ (- 60 ?score) 25.0)))
   (return 0.0))

(deffunction fuzzy-budget-medium (?score)
   (if (or (<= ?score 30) (>= ?score 85)) then
      (return 0.0))
   (if (and (> ?score 30) (< ?score 60)) then
      (return (/ (- ?score 30) 30.0)))
   (if (and (>= ?score 60) (< ?score 85)) then
      (return (/ (- 85 ?score) 25.0)))
   (return 0.0))

(deffunction fuzzy-budget-high (?score)
   (if (<= ?score 65) then
      (return 0.0))
   (if (and (> ?score 65) (< ?score 90)) then
      (return (/ (- ?score 65) 25.0)))
   (return 1.0))

(deffunction fuzzy-urgency-low (?score)
   (if (<= ?score 30) then
      (return 1.0))
   (if (and (> ?score 30) (< ?score 60)) then
      (return (/ (- 60 ?score) 30.0)))
   (return 0.0))

(deffunction fuzzy-urgency-high (?score)
   (if (<= ?score 50) then
      (return 0.0))
   (if (and (> ?score 50) (< ?score 85)) then
      (return (/ (- ?score 50) 35.0)))
   (return 1.0))

(deffunction fuzzy-repair-cost-high (?percent)
   (if (<= ?percent 30) then
      (return 0.0))
   (if (and (> ?percent 30) (< ?percent 70)) then
      (return (/ (- ?percent 30) 40.0)))
   (return 1.0))

(deffunction combine-cf (?cf1 ?cf2)
   (if (and (> ?cf1 0) (> ?cf2 0)) then
      (return (+ ?cf1 (* ?cf2 (- 1 ?cf1)))))

   (if (and (< ?cf1 0) (< ?cf2 0)) then
      (return (+ ?cf1 (* ?cf2 (+ 1 ?cf1)))))

   (return (/ (+ ?cf1 ?cf2)
              (- 1 (min (abs ?cf1) (abs ?cf2))))))
