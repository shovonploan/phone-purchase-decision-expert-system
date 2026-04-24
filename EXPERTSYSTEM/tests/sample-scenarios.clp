(deffunction clear-phone-users ()
   (do-for-all-facts ((?u phone-user)) TRUE
      (retract ?u)))

(deffunction ask-choice (?label $?allowed)
   (bind ?answer INVALID)
   (bind ?default (nth$ 1 ?allowed))
   (bind ?allowed-text "")
   (bind ?idx 1)
   (while (<= ?idx (length$ ?allowed)) do
      (if (= ?idx 1)
         then
         (bind ?allowed-text (str-cat (nth$ ?idx ?allowed)))
         else
         (bind ?allowed-text (str-cat ?allowed-text ", " (nth$ ?idx ?allowed))))
      (bind ?idx (+ ?idx 1)))
   (while (not (member$ ?answer ?allowed)) do
      (printout t ?label " (" ?allowed-text "): ")
      (bind ?answer (read))
      (if (eq ?answer EOF) then
         (printout t crlf "Input ended. Using default for " ?label ": " ?default crlf)
         (return ?default))
      (if (not (member$ ?answer ?allowed)) then
         (printout t "Invalid value. Choose one of: " ?allowed-text crlf)))
   (return ?answer))

(deffunction ask-int (?label ?min ?max)
   (bind ?value INVALID)
   (while (or (not (integerp ?value)) (< ?value ?min) (> ?value ?max)) do
      (printout t ?label " (" ?min "-" ?max "): ")
      (bind ?value (read))
      (if (eq ?value EOF) then
         (printout t crlf "Input ended. Using default for " ?label ": " ?min crlf)
         (return ?min))
      (if (or (not (integerp ?value)) (< ?value ?min) (> ?value ?max)) then
         (printout t "Invalid integer. Use a value in " ?min "-" ?max "." crlf)))
   (return ?value))

(deffunction budget-cad-to-level (?cad)
   (if (<= ?cad 500) then (return low))
   (if (<= ?cad 1200) then (return medium))
   (return high))

(deffunction budget-cad-to-score (?cad)
   (if (<= ?cad 200) then (return 10))
   (if (<= ?cad 500) then (return 30))
   (if (<= ?cad 800) then (return 50))
   (if (<= ?cad 1200) then (return 70))
   (if (<= ?cad 1800) then (return 85))
   (return 95))

(deffunction battery-percent-to-health (?pct)
   (if (>= ?pct 80) then (return good))
   (if (>= ?pct 55) then (return moderate))
   (if (>= ?pct 30) then (return poor))
   (return very-poor))

(deffunction performance-score-to-level (?score)
   (if (>= ?score 80) then (return fast))
   (if (>= ?score 60) then (return acceptable))
   (if (>= ?score 35) then (return slow))
   (return very-slow))

(deffunction urgency-score-to-level (?score)
   (if (>= ?score 70) then (return high))
   (if (>= ?score 40) then (return medium))
   (return low))

(deffunction repair-percent-to-level (?pct)
   (if (>= ?pct 75) then (return very-high))
   (if (>= ?pct 50) then (return high))
   (if (>= ?pct 25) then (return medium))
   (return low))

(deffunction run-interactive ()
   (reset)
   (clear-phone-users)

   (printout t crlf "Interactive Phone Profile" crlf)
   (printout t "=========================" crlf)
   (printout t "Answer these questions about your current phone and your upgrade preferences." crlf crlf)

   (bind ?phone-age (ask-choice "Current phone age" (create$ new moderate old very-old)))
   (bind ?battery-health-percent (ask-int "Current battery health percent" 0 100))
   (bind ?performance-score (ask-int "Current performance score" 0 100))
   (bind ?storage-status (ask-choice "Current storage status" (create$ enough almost-full full)))
   (bind ?physical-condition (ask-choice "Current physical condition" (create$ good minor-damage major-damage broken)))
   (bind ?software-support (ask-choice "Current software support status" (create$ supported limited unsupported)))
   (bind ?platform (ask-choice "Current platform/ecosystem" (create$ ios android other)))
   (bind ?repair-cost-percent (ask-int "Estimated repair cost percent of replacement price" 0 100))
   (bind ?budget-cad (ask-int "Your budget in CAD" 0 20000))
   (bind ?urgency-score (ask-int "How urgent is replacement for you (score)" 0 100))
   (bind ?camera-need (ask-choice "Your camera need level" (create$ low medium high)))
   (bind ?gaming-need (ask-choice "Your gaming/performance need level" (create$ low medium high)))
   (bind ?work-study-dependence (ask-choice "How much you depend on phone for work/study" (create$ low medium high)))
   (bind ?latest-model-importance (ask-choice "Importance of getting latest model" (create$ low medium high)))

   (bind ?battery-health (battery-percent-to-health ?battery-health-percent))
   (bind ?battery-score ?battery-health-percent)
   (bind ?performance (performance-score-to-level ?performance-score))
   (bind ?budget-level (budget-cad-to-level ?budget-cad))
   (bind ?budget-score (budget-cad-to-score ?budget-cad))
   (bind ?urgency (urgency-score-to-level ?urgency-score))
   (bind ?repair-cost-level (repair-percent-to-level ?repair-cost-percent))

   (if (eq ?budget-level high)
      then
      (bind ?used-phone-comfort no)
      (printout t "used-phone-comfort auto-set to 'no' for high-budget profile." crlf)
      else
      (bind ?used-phone-comfort (ask-choice "Comfort with used/refurbished phones" (create$ yes no maybe))))

   (bind ?trade-in-available (ask-choice "Trade-in available for current phone" (create$ yes no)))

   (assert
      (phone-user
         (phone-age ?phone-age)
         (battery-health ?battery-health)
         (performance ?performance)
         (storage-status ?storage-status)
         (physical-condition ?physical-condition)
         (software-support ?software-support)
         (platform ?platform)
         (repair-cost-level ?repair-cost-level)
         (budget-cad ?budget-cad)
         (budget-level ?budget-level)
         (urgency ?urgency)
         (camera-need ?camera-need)
         (gaming-need ?gaming-need)
         (work-study-dependence ?work-study-dependence)
         (latest-model-importance ?latest-model-importance)
         (used-phone-comfort ?used-phone-comfort)
         (trade-in-available ?trade-in-available)
         (battery-health-percent ?battery-health-percent)
         (battery-score ?battery-score)
         (performance-score ?performance-score)
         (budget-score ?budget-score)
         (urgency-score ?urgency-score)
         (repair-cost-percent ?repair-cost-percent)))

   (run)
   (print-results)
   (return TRUE))

(deffunction assert-scenario (?id)
   (if (eq ?id "scenario-01") then
      (assert
         (phone-user
            (phone-age very-old)
            (battery-health very-poor)
            (performance very-slow)
            (storage-status full)
            (physical-condition minor-damage)
            (software-support unsupported)
            (platform android)
            (repair-cost-level high)
            (budget-cad 1000)
            (budget-level medium)
            (urgency high)
            (camera-need medium)
            (gaming-need low)
            (work-study-dependence high)
            (latest-model-importance low)
            (used-phone-comfort maybe)
            (trade-in-available yes)
            (battery-health-percent 15)
            (battery-score 15)
            (performance-score 20)
            (budget-score 60)
            (urgency-score 90)
            (repair-cost-percent 75)))
      (return TRUE))

   (if (eq ?id "scenario-02") then
      (assert
         (phone-user
            (phone-age moderate)
            (battery-health good)
            (performance fast)
            (storage-status enough)
            (physical-condition good)
            (software-support supported)
            (platform android)
            (repair-cost-level low)
            (budget-cad 800)
            (budget-level medium)
            (urgency low)
            (camera-need medium)
            (gaming-need low)
            (work-study-dependence medium)
            (latest-model-importance low)
            (used-phone-comfort no)
            (trade-in-available no)
            (battery-health-percent 85)
            (battery-score 85)
            (performance-score 88)
            (budget-score 55)
            (urgency-score 20)
            (repair-cost-percent 10)))
      (return TRUE))

   (if (eq ?id "scenario-03") then
      (assert
         (phone-user
            (phone-age moderate)
            (battery-health very-poor)
            (performance acceptable)
            (storage-status enough)
            (physical-condition good)
            (software-support supported)
            (platform android)
            (repair-cost-level medium)
            (budget-cad 700)
            (budget-level medium)
            (urgency medium)
            (camera-need low)
            (gaming-need low)
            (work-study-dependence high)
            (latest-model-importance low)
            (used-phone-comfort maybe)
            (trade-in-available no)
            (battery-health-percent 18)
            (battery-score 18)
            (performance-score 70)
            (budget-score 55)
            (urgency-score 50)
            (repair-cost-percent 25)))
      (return TRUE))

   (if (eq ?id "scenario-04") then
      (assert
         (phone-user
            (phone-age old)
            (battery-health poor)
            (performance slow)
            (storage-status almost-full)
            (physical-condition minor-damage)
            (software-support limited)
            (platform android)
            (repair-cost-level high)
            (budget-cad 400)
            (budget-level low)
            (urgency high)
            (camera-need medium)
            (gaming-need low)
            (work-study-dependence high)
            (latest-model-importance low)
            (used-phone-comfort yes)
            (trade-in-available yes)
            (battery-health-percent 30)
            (battery-score 30)
            (performance-score 35)
            (budget-score 25)
            (urgency-score 85)
            (repair-cost-percent 65)))
      (return TRUE))

   (if (eq ?id "scenario-05") then
      (assert
         (phone-user
            (phone-age old)
            (battery-health moderate)
            (performance slow)
            (storage-status almost-full)
            (physical-condition good)
            (software-support limited)
            (platform ios)
            (repair-cost-level medium)
            (budget-cad 1800)
            (budget-level high)
            (urgency medium)
            (camera-need high)
            (gaming-need high)
            (work-study-dependence high)
            (latest-model-importance high)
            (used-phone-comfort no)
            (trade-in-available yes)
            (battery-health-percent 55)
            (battery-score 55)
            (performance-score 45)
            (budget-score 90)
            (urgency-score 65)
            (repair-cost-percent 35)))
      (return TRUE))

   (printout t "Unknown scenario id: " ?id crlf)
   (return FALSE))

(deffunction run-scenario (?id)
   (reset)
   (clear-phone-users)
   (if (assert-scenario ?id) then
      (run)
      (print-results)
      (return TRUE))
   (return FALSE))

(deffunction run-scenario-silent (?id)
   (reset)
   (clear-phone-users)
   (if (assert-scenario ?id) then
      (run)
      (return TRUE))
   (return FALSE))

(deffunction expected-primary-rule (?id)
   (if (eq ?id "scenario-01") then (return R19))
   (if (eq ?id "scenario-02") then (return R20))
   (if (eq ?id "scenario-03") then (return NONE))
   (if (eq ?id "scenario-04") then (return R17))
   (if (eq ?id "scenario-05") then (return R24))
   (return NONE))

(deffunction expected-cf-rule (?id)
   (if (eq ?id "scenario-01") then (return BUY-NEW-CF))
   (if (eq ?id "scenario-02") then (return KEEP-CURRENT-CF))
   (if (eq ?id "scenario-03") then (return BATTERY-REPLACE-CF))
   (if (eq ?id "scenario-04") then (return REFURB-CF))
   (if (eq ?id "scenario-05") then (return FLAGSHIP-CF))
   (return NONE))

(deffunction expected-final-rule (?id)
   (if (eq ?id "scenario-01") then (return FINAL-BUY-NEW))
   (if (eq ?id "scenario-02") then (return FINAL-KEEP))
   (if (eq ?id "scenario-03") then (return FINAL-REPLACE-BATTERY))
   (if (eq ?id "scenario-04") then (return FINAL-BUY-NEW))
   (if (eq ?id "scenario-05") then (return FINAL-BUY-FLAGSHIP))
   (return NONE))

(deffunction recommendation-exists (?rule-id)
   (bind ?found FALSE)
   (do-for-all-facts ((?r recommendation)) TRUE
      (if (eq ?r:rule-id ?rule-id) then
         (bind ?found TRUE)))
   (return ?found))

(deffunction recommendation-cf-exists (?rule-id)
   (bind ?found FALSE)
   (do-for-all-facts ((?r recommendation-cf)) TRUE
      (if (eq ?r:rule-id ?rule-id) then
         (bind ?found TRUE)))
   (return ?found))

(deffunction final-decision-exists (?rule-id)
   (bind ?found FALSE)
   (do-for-all-facts ((?d final-decision)) TRUE
      (if (eq ?d:rule-id ?rule-id) then
         (bind ?found TRUE)))
   (return ?found))

(deffunction cf-not-exists (?rule-id)
   (return (not (recommendation-cf-exists ?rule-id))))

(deffunction phone-category-exists (?category)
   (bind ?found FALSE)
   (do-for-all-facts ((?c phone-category-suggestion)) TRUE
      (if (eq ?c:category ?category) then
         (bind ?found TRUE)))
   (return ?found))

(deffunction test-scenario-negative-cf (?id)
   (if (eq ?id "scenario-01") then
      (if (or
            (recommendation-cf-exists KEEP-CURRENT-CF)
            (recommendation-cf-exists WAIT-CF))
         then
         (progn
            (printout t "[FAIL] scenario-01 produced forbidden keep/wait CF rules." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-02") then
      (if (or
            (recommendation-cf-exists BUY-NEW-CF)
            (recommendation-cf-exists BATTERY-REPLACE-CF)
            (recommendation-cf-exists REPAIR-CF)
            (recommendation-cf-exists MID-RANGE-CF)
            (recommendation-cf-exists FLAGSHIP-CF))
         then
         (progn
            (printout t "[FAIL] scenario-02 produced forbidden upgrade CF rules." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-03") then
      (if (or
            (recommendation-cf-exists BUY-NEW-CF)
            (recommendation-cf-exists FLAGSHIP-CF))
         then
         (progn
            (printout t "[FAIL] scenario-03 produced forbidden aggressive-buy CF rules." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-04") then
      (if (recommendation-cf-exists FLAGSHIP-CF)
         then
         (progn
            (printout t "[FAIL] scenario-04 should not produce FLAGSHIP-CF." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-05") then
      (if (or
            (recommendation-cf-exists BATTERY-REPLACE-CF)
            (recommendation-cf-exists REPAIR-CF)
            (recommendation-cf-exists REFURB-CF))
         then
         (progn
            (printout t "[FAIL] scenario-05 produced forbidden battery/repair/refurb CF rules." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (return TRUE))

(deffunction test-scenario-negative-category (?id)
   (if (eq ?id "scenario-02") then
      (if (or
            (phone-category-exists mid-range)
            (phone-category-exists refurbished)
            (phone-category-exists flagship)
            (phone-category-exists budget-upgrade)
            (phone-category-exists premium-or-flagship))
         then
         (progn
            (printout t "[FAIL] scenario-02 produced forbidden upgrade categories." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-03") then
      (if (or
            (phone-category-exists flagship)
            (phone-category-exists premium-or-flagship))
         then
         (progn
            (printout t "[FAIL] scenario-03 produced forbidden high-end categories." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-04") then
      (if (phone-category-exists flagship)
         then
         (progn
            (printout t "[FAIL] scenario-04 should not produce flagship category." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (return TRUE))

(deffunction test-scenario-negative-final (?id)
   (if (eq ?id "scenario-01") then
      (if (or
            (final-decision-exists FINAL-KEEP)
            (final-decision-exists FINAL-WAIT))
         then
         (progn
            (printout t "[FAIL] scenario-01 produced forbidden final decision (keep/wait)." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (if (eq ?id "scenario-05") then
      (if (or
            (final-decision-exists FINAL-KEEP)
            (final-decision-exists FINAL-WAIT)
            (final-decision-exists FINAL-REPAIR)
            (final-decision-exists FINAL-REPLACE-BATTERY))
         then
         (progn
            (printout t "[FAIL] scenario-05 produced forbidden conservative final decision." crlf)
            (return FALSE))
         else
         (return TRUE)))

   (return TRUE))

(deffunction test-scenario (?id)
   (printout t crlf "[TEST] Running " ?id crlf)

   (if (not (run-scenario-silent ?id)) then
      (printout t "[FAIL] Could not run scenario." crlf)
      (return FALSE))

   (bind ?expected-main (expected-primary-rule ?id))
   (bind ?expected-cf (expected-cf-rule ?id))
   (bind ?expected-final (expected-final-rule ?id))

   (bind ?main-pass TRUE)
   (if (neq ?expected-main NONE) then
      (bind ?main-pass (recommendation-exists ?expected-main)))
   (bind ?cf-pass (recommendation-cf-exists ?expected-cf))
   (bind ?final-pass (final-decision-exists ?expected-final))
   (bind ?negative-pass (test-scenario-negative-cf ?id))
   (bind ?negative-cat-pass (test-scenario-negative-category ?id))
   (bind ?negative-final-pass (test-scenario-negative-final ?id))

   (if (eq ?expected-main NONE)
      then
      (printout t "[PASS] No mandatory deterministic recommendation expected." crlf)
      else
      (if ?main-pass
         then
         (printout t "[PASS] Found expected recommendation rule: " ?expected-main crlf)
         else
         (printout t "[FAIL] Missing expected recommendation rule: " ?expected-main crlf)))

   (if ?cf-pass
      then
      (printout t "[PASS] Found expected CF rule: " ?expected-cf crlf)
      else
      (printout t "[FAIL] Missing expected CF rule: " ?expected-cf crlf))

   (if ?final-pass
      then
      (printout t "[PASS] Found expected final decision rule: " ?expected-final crlf)
      else
      (printout t "[FAIL] Missing expected final decision rule: " ?expected-final crlf))

   (if ?negative-pass
      then
      (printout t "[PASS] Forbidden CF checks passed for " ?id "." crlf))

   (if ?negative-cat-pass
      then
      (printout t "[PASS] Forbidden category checks passed for " ?id "." crlf))

   (if ?negative-final-pass
      then
      (printout t "[PASS] Forbidden final-decision checks passed for " ?id "." crlf))

   (if (and ?main-pass ?cf-pass ?final-pass ?negative-pass ?negative-cat-pass ?negative-final-pass)
      then
      (printout t "[PASS] Scenario " ?id " validation passed." crlf)
      else
      (printout t "[FAIL] Scenario " ?id " validation failed." crlf))

   (return (and ?main-pass ?cf-pass ?final-pass ?negative-pass ?negative-cat-pass ?negative-final-pass)))

(deffunction run-all-scenario-tests ()
   (bind ?pass-count 0)
   (bind ?total 5)

   (if (test-scenario "scenario-01") then (bind ?pass-count (+ ?pass-count 1)))
   (if (test-scenario "scenario-02") then (bind ?pass-count (+ ?pass-count 1)))
   (if (test-scenario "scenario-03") then (bind ?pass-count (+ ?pass-count 1)))
   (if (test-scenario "scenario-04") then (bind ?pass-count (+ ?pass-count 1)))
   (if (test-scenario "scenario-05") then (bind ?pass-count (+ ?pass-count 1)))

   (printout t crlf "[SUMMARY] Passed " ?pass-count " / " ?total " scenario tests." crlf)

   (if (= ?pass-count ?total)
      then
      (printout t "[SUMMARY] ALL TESTS PASSED" crlf)
      else
      (printout t "[SUMMARY] SOME TESTS FAILED" crlf))

   (return (= ?pass-count ?total)))
