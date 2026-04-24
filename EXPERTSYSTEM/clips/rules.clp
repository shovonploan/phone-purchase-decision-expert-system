(deffunction count-model-suggestions (?rule-id)
   (bind ?count 0)
   (do-for-all-facts ((?m phone-model-suggestion)) TRUE
      (if (eq ?m:rule-id ?rule-id) then
         (bind ?count (+ ?count 1))))
   (return ?count))

; Inference layer
(defrule infer-no-upgrade-needed
   (phone-user
      (phone-age new|moderate)
      (battery-health good|moderate)
      (performance fast|acceptable)
      (physical-condition good)
      (software-support supported))
   =>
   (assert (no-upgrade-needed
      (reason phone-still-healthy))))

(defrule infer-replacement-needed-multiple-issues
   (phone-user
      (phone-age old|very-old)
      (battery-health poor|very-poor)
      (performance slow|very-slow))
   =>
   (assert (replacement-needed
      (reason multiple-major-issues)
      (strength high))))

(defrule infer-replacement-needed-old-unsupported
   (phone-user
      (phone-age old|very-old)
      (software-support unsupported))
   =>
   (assert (replacement-needed
      (reason old-and-unsupported)
      (strength high))))

(defrule infer-replacement-needed-broken-expensive
   (phone-user
      (physical-condition broken|major-damage)
      (repair-cost-level high|very-high))
   =>
   (assert (replacement-needed
      (reason broken-and-expensive-repair)
      (strength high))))

(defrule infer-replacement-needed-medium-degradation
   (phone-user
      (phone-age moderate|old)
      (battery-health poor|very-poor)
      (software-support limited|unsupported)
      (repair-cost-level medium|high|very-high))
   =>
   (assert (replacement-needed
      (reason degradation-and-risk)
      (strength medium))))

(defrule infer-replacement-needed-medium-performance
   (phone-user
      (phone-age moderate|old|very-old)
      (performance slow|very-slow)
      (software-support limited|unsupported))
   =>
   (assert (replacement-needed
      (reason weak-performance-and-support)
      (strength medium))))

; Findings
(defrule finding-very-old-phone
   (phone-user (phone-age very-old))
   =>
   (assert (finding
      (rule-id F1)
      (message "Your phone is very old."))))

(defrule finding-poor-battery
   (phone-user (battery-health poor|very-poor))
   (not (advice-category-fired (category battery)))
   =>
   (assert (finding
      (rule-id F2)
      (message "Battery health is poor.")))
   (assert (advice-category-fired (category battery))))

(defrule finding-slow-performance
   (phone-user (performance slow|very-slow))
   =>
   (assert (finding
      (rule-id F3)
      (message "Performance is slow for current needs."))))

(defrule finding-full-storage
   (phone-user (storage-status full))
   =>
   (assert (finding
      (rule-id F4)
      (message "Storage is full."))))

(defrule finding-unsupported-software
   (phone-user (software-support unsupported))
   =>
   (assert (finding
      (rule-id F5)
      (message "Software/security support is no longer available."))))

; Action recommendations
(defrule rule-18-trade-in
   (phone-user (trade-in-available yes))
   =>
   (assert (recommendation
      (rule-id R18)
      (message "Check trade-in value if you decide to upgrade."))))

(defrule rule-17-refurbished-option
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level low|medium)
      (used-phone-comfort yes|maybe))
   =>
   (assert (recommendation
      (rule-id R17)
      (message "A certified refurbished phone may be a good option because it balances cost and quality."))))

(defrule rule-19-buy-new-phone
   (replacement-needed (strength high))
   (not (no-upgrade-needed))
   (phone-user (budget-level medium|high))
   =>
   (assert (recommendation
      (rule-id R19)
      (message "Buying a new phone is recommended because your current phone has multiple major issues."))))

(defrule rule-20-keep-current-phone
   (no-upgrade-needed)
   (phone-user (urgency low|medium))
   =>
   (assert (recommendation
      (rule-id R20)
      (message "Keeping your current phone is recommended because it still meets your needs."))))

(defrule rule-21-repair-instead
   (not (no-upgrade-needed))
   (phone-user
      (physical-condition minor-damage|major-damage)
      (repair-cost-level low|medium)
      (performance fast|acceptable)
      (software-support supported|limited))
   =>
   (assert (recommendation
      (rule-id R21)
      (message "Repairing the current phone is more sensible than buying a new one."))))

(defrule rule-22-avoid-flagship
   (phone-user
      (budget-level low|medium)
      (latest-model-importance high)
      (camera-need low|medium)
      (gaming-need low|medium))
   =>
   (assert (warning
      (rule-id R22)
      (message "A flagship phone may not be necessary because your feature needs do not strongly justify it."))))

(defrule rule-23-buy-mid-range
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level medium)
      (camera-need medium|high)
      (gaming-need low|medium)
      (work-study-dependence medium|high))
   =>
   (assert (recommendation
      (rule-id R23)
      (message "A mid-range phone is likely the best balance of price, performance, camera, and reliability."))))

(defrule rule-24-buy-flagship
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level high)
      (camera-need high)
      (gaming-need high)
      (work-study-dependence high))
   =>
   (assert (recommendation
      (rule-id R24)
      (message "A flagship phone may be justified because you have high performance, camera, and reliability needs."))))

(defrule rule-25-wait-before-buying
   (not (replacement-needed))
   (phone-user
      (urgency low)
      (phone-age new|moderate)
      (performance fast|acceptable)
      (battery-health good|moderate))
   =>
   (assert (recommendation
      (rule-id R25)
      (message "Waiting is recommended because your current phone is still usable and your need is not urgent."))))

(defrule warning-unsupported-software
   (phone-user (software-support unsupported))
   =>
   (assert (warning
      (rule-id R8)
      (message "Your phone is no longer receiving software/security updates. This increases privacy and security risk."))))

; Certainty-factor rules (strict gates)
(defrule cf-buy-new-phone
   (replacement-needed (strength high|medium))
   (not (no-upgrade-needed))
   (phone-user
      (phone-age ?age)
      (battery-health ?battery)
      (performance ?perf)
      (software-support ?support)
      (budget-level ?budget)
      (repair-cost-percent ?repair))
   =>
   (bind ?cf 0.45)
   (if (or (eq ?age old) (eq ?age very-old)) then (bind ?cf (+ ?cf 0.15)))
   (if (or (eq ?battery poor) (eq ?battery very-poor)) then (bind ?cf (+ ?cf 0.10)))
   (if (or (eq ?perf slow) (eq ?perf very-slow)) then (bind ?cf (+ ?cf 0.10)))
   (if (eq ?support unsupported) then (bind ?cf (+ ?cf 0.10)))
   (if (> ?repair 60) then (bind ?cf (+ ?cf 0.10)))
   (if (eq ?budget low) then (bind ?cf (- ?cf 0.10)))
   (if (> ?cf 1.0) then (bind ?cf 1.0))
   (if (> ?cf 0.55) then
      (assert (recommendation-cf
         (rule-id BUY-NEW-CF)
         (message "Buying a new phone is recommended based on combined evidence.")
         (certainty ?cf)))))

(defrule cf-wait-before-buying
   (not (replacement-needed (strength high|medium)))
   (phone-user
      (urgency ?urgency)
      (phone-age ?age)
      (battery-health ?battery)
      (performance ?perf)
      (software-support ?support))
   =>
   (bind ?cf 0.25)
   (if (eq ?urgency low) then (bind ?cf (+ ?cf 0.30)))
   (if (or (eq ?age new) (eq ?age moderate)) then (bind ?cf (+ ?cf 0.15)))
   (if (or (eq ?battery good) (eq ?battery moderate)) then (bind ?cf (+ ?cf 0.10)))
   (if (or (eq ?perf fast) (eq ?perf acceptable)) then (bind ?cf (+ ?cf 0.10)))
   (if (eq ?support supported) then (bind ?cf (+ ?cf 0.10)))
   (if (> ?cf 1.0) then (bind ?cf 1.0))
   (if (> ?cf 0.50) then
      (assert (recommendation-cf
         (rule-id WAIT-CF)
         (message "Supporting advice: waiting is reasonable because your current phone is still usable.")
         (certainty ?cf)))))

(defrule cf-replace-battery
   (not (no-upgrade-needed))
   (phone-user
      (battery-health poor|very-poor)
      (performance fast|acceptable)
      (physical-condition good|minor-damage)
      (software-support supported|limited)
      (repair-cost-percent ?repair&:(<= ?repair 45)))
   =>
   (bind ?cf 0.65)
   (if (<= ?repair 25) then
      (bind ?cf (+ ?cf 0.15)))
   (if (> ?cf 1.0) then
      (bind ?cf 1.0))
   (assert (recommendation-cf
      (rule-id BATTERY-REPLACE-CF)
      (message "Replacing the battery is likely a cost-effective choice.")
      (certainty ?cf))))

(defrule cf-repair-instead-of-buy
   (not (no-upgrade-needed))
   (phone-user
      (physical-condition minor-damage|major-damage)
      (repair-cost-level low|medium)
      (performance fast|acceptable)
      (software-support supported|limited))
   =>
   (bind ?cf 0.65)
   (assert (recommendation-cf
      (rule-id REPAIR-CF)
      (message "Repairing your current phone is likely better than replacing it right now.")
      (certainty ?cf))))

(defrule cf-buy-refurbished
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level low|medium)
      (used-phone-comfort ?comfort&yes|maybe))
   =>
   (bind ?cf 0.60)
   (if (eq ?comfort yes) then
      (bind ?cf (+ ?cf 0.10)))
   (if (> ?cf 1.0) then (bind ?cf 1.0))
   (assert (recommendation-cf
      (rule-id REFURB-CF)
      (message "A certified refurbished phone is a strong value option for your profile.")
      (certainty ?cf))))

(defrule cf-buy-mid-range
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level medium)
      (camera-need medium|high)
      (gaming-need low|medium)
      (work-study-dependence medium|high))
   =>
   (bind ?cf 0.65)
   (assert (recommendation-cf
      (rule-id MID-RANGE-CF)
      (message "A mid-range phone is likely your best overall value.")
      (certainty ?cf))))

(defrule cf-buy-flagship
   (replacement-needed (strength medium|high))
   (not (no-upgrade-needed))
   (phone-user
      (budget-level high)
      (camera-need high)
      (gaming-need high)
      (work-study-dependence high)
      (latest-model-importance ?latest))
   =>
   (bind ?cf 0.70)
   (if (eq ?latest high) then (bind ?cf (+ ?cf 0.10)))
   (if (> ?cf 1.0) then (bind ?cf 1.0))
   (assert (recommendation-cf
      (rule-id FLAGSHIP-CF)
      (message "A flagship phone is justified by your high-end requirements.")
      (certainty ?cf))))

(defrule cf-keep-current
   (no-upgrade-needed)
   (phone-user
      (phone-age ?age)
      (battery-health ?battery)
      (performance ?perf)
      (software-support ?support)
      (urgency ?urgency))
   =>
   (bind ?cf 0.55)
   (if (or (eq ?age new) (eq ?age moderate)) then (bind ?cf (+ ?cf 0.10)))
   (if (or (eq ?battery good) (eq ?battery moderate)) then (bind ?cf (+ ?cf 0.10)))
   (if (or (eq ?perf fast) (eq ?perf acceptable)) then (bind ?cf (+ ?cf 0.10)))
   (if (eq ?support supported) then (bind ?cf (+ ?cf 0.10)))
   (if (eq ?urgency low) then (bind ?cf (+ ?cf 0.05)))
   (if (> ?cf 1.0) then (bind ?cf 1.0))
   (assert (recommendation-cf
      (rule-id KEEP-CURRENT-CF)
      (message "Keeping your current phone remains a sound decision for now.")
      (certainty ?cf))))

; Fuzzy rules
(defrule rule-fuzzy-poor-battery
   (phone-user (battery-score ?score))
   =>
   (bind ?cf (fuzzy-battery-poor ?score))
   (if (> ?cf 0.30) then
      (assert (recommendation-cf
         (rule-id FUZZY-BATTERY-POOR)
         (message "Fuzzy evidence: battery condition strongly supports replacement consideration.")
         (certainty ?cf)))))

(defrule rule-fuzzy-poor-performance
   (phone-user (performance-score ?score))
   =>
   (bind ?cf (fuzzy-performance-poor ?score))
   (if (> ?cf 0.30) then
      (assert (recommendation-cf
         (rule-id FUZZY-PERFORMANCE-POOR)
         (message "Fuzzy evidence: weak performance supports upgrade consideration.")
         (certainty ?cf)))))

(defrule rule-fuzzy-high-repair-cost
   (phone-user (repair-cost-percent ?percent))
   =>
   (bind ?cf (fuzzy-repair-cost-high ?percent))
   (if (> ?cf 0.30) then
      (assert (recommendation-cf
         (rule-id FUZZY-REPAIR-HIGH)
         (message "Fuzzy evidence: high repair cost supports replacement consideration.")
         (certainty ?cf)))))

(defrule rule-fuzzy-high-budget-high-urgency
   (replacement-needed (strength medium|high))
   (phone-user
      (budget-score ?budget)
      (urgency-score ?urgency))
   =>
   (bind ?budget-cf (fuzzy-budget-high ?budget))
   (bind ?urgency-cf (fuzzy-urgency-high ?urgency))
   (bind ?cf (min ?budget-cf ?urgency-cf))
   (if (> ?cf 0.30) then
      (assert (recommendation-cf
         (rule-id FUZZY-BUDGET-URGENCY)
         (message "Fuzzy evidence: budget and urgency together support near-term replacement.")
         (certainty ?cf)))))

(defrule rule-fuzzy-low-urgency
   (not (replacement-needed (strength high|medium)))
   (phone-user (urgency-score ?score))
   =>
   (bind ?cf (fuzzy-urgency-low ?score))
   (if (> ?cf 0.30) then
      (assert (recommendation-cf
         (rule-id FUZZY-WAIT)
         (message "Fuzzy evidence: low urgency supports waiting.")
         (certainty ?cf)))))

; Final decision layer
(defrule final-decision-buy-new
   (declare (salience -106))
   (not (final-decision))
   (recommendation-cf
      (rule-id BUY-NEW-CF)
      (certainty ?buy&:(>= ?buy 0.70)))
   =>
   (assert (final-decision
      (decision buy-new)
      (rule-id FINAL-BUY-NEW)
      (message "Final decision: buying a replacement phone is recommended.")
      (certainty ?buy))))

(defrule final-decision-keep-current
   (declare (salience -100))
   (not (final-decision))
   (recommendation-cf
      (rule-id KEEP-CURRENT-CF)
      (certainty ?keep&:(>= ?keep 0.70)))
   (not (recommendation-cf
      (rule-id BUY-NEW-CF)
      (certainty ?buy&:(> ?buy ?keep))))
   =>
   (assert (final-decision
      (decision keep-current)
      (rule-id FINAL-KEEP)
      (message "Final decision: keep your current phone for now.")
      (certainty ?keep))))

(defrule final-decision-replace-battery
   (declare (salience -101))
   (not (final-decision))
   (recommendation-cf
      (rule-id BATTERY-REPLACE-CF)
      (certainty ?bat&:(>= ?bat 0.70)))
   =>
   (assert (final-decision
      (decision replace-battery)
      (rule-id FINAL-REPLACE-BATTERY)
      (message "Final decision: replace the battery before buying a new phone.")
      (certainty ?bat))))

(defrule final-decision-repair
   (declare (salience -102))
   (not (final-decision))
   (recommendation-cf
      (rule-id REPAIR-CF)
      (certainty ?rep&:(>= ?rep 0.70)))
   =>
   (assert (final-decision
      (decision repair)
      (rule-id FINAL-REPAIR)
      (message "Final decision: repairing the current phone is recommended.")
      (certainty ?rep))))

(defrule final-decision-buy-flagship
   (declare (salience -103))
   (not (final-decision))
   (recommendation-cf
      (rule-id FLAGSHIP-CF)
      (certainty ?flag&:(>= ?flag 0.70)))
   (not (recommendation-cf
      (rule-id BUY-NEW-CF)
      (certainty ?buy&:(> ?buy ?flag))))
   =>
   (assert (final-decision
      (decision buy-flagship)
      (rule-id FINAL-BUY-FLAGSHIP)
      (message "Final decision: buy a flagship phone that matches your high-end needs.")
      (certainty ?flag))))

(defrule final-decision-buy-midrange
   (declare (salience -104))
   (not (final-decision))
   (recommendation-cf
      (rule-id MID-RANGE-CF)
      (certainty ?mid&:(>= ?mid 0.65)))
   (not (recommendation-cf
      (rule-id BUY-NEW-CF)
      (certainty ?buy&:(>= ?buy ?mid))))
   =>
   (assert (final-decision
      (decision buy-mid-range)
      (rule-id FINAL-BUY-MIDRANGE)
      (message "Final decision: buy a reliable mid-range phone.")
      (certainty ?mid))))

(defrule final-decision-buy-refurb
   (declare (salience -105))
   (not (final-decision))
   (recommendation-cf
      (rule-id REFURB-CF)
      (certainty ?ref&:(>= ?ref 0.60)))
   (not (recommendation-cf
      (rule-id BUY-NEW-CF)
      (certainty ?buy&:(>= ?buy ?ref))))
   =>
   (assert (final-decision
      (decision buy-refurbished)
      (rule-id FINAL-BUY-REFURB)
      (message "Final decision: buy a certified refurbished phone.")
      (certainty ?ref))))

; Category suggestions (clean summary layer)
(defrule category-keep-current
   (final-decision (decision keep-current|wait))
   =>
   (assert (phone-category-suggestion
      (category keep-current)
      (rule-id C-KEEP)
      (message "Suggested category: keep current phone and review again after major degradation or discounts."))))

(defrule category-repair
   (final-decision (decision repair))
   =>
   (assert (phone-category-suggestion
      (category repair)
      (rule-id C-REPAIR)
      (message "Suggested category: repair-first path with low-to-medium repair investment."))))

(defrule category-replace-battery
   (final-decision (decision replace-battery))
   =>
   (assert (phone-category-suggestion
      (category battery-service)
      (rule-id C-BATTERY)
      (message "Suggested category: battery-service path before considering replacement."))))

(defrule category-mid-range
   (final-decision (decision buy-mid-range))
   =>
   (assert (phone-category-suggestion
      (category mid-range)
      (rule-id C-MID)
      (message "Suggested category: reliable mid-range phone with balanced performance and value."))))

(defrule category-refurb
   (final-decision (decision buy-refurbished))
   =>
   (assert (phone-category-suggestion
      (category refurbished)
      (rule-id C-REFURB)
      (message "Suggested category: certified refurbished premium or flagship devices."))))

(defrule category-flagship
   (final-decision (decision buy-flagship))
   =>
   (assert (phone-category-suggestion
      (category flagship)
      (rule-id C-FLAG)
      (message "Suggested category: high-end flagship devices for demanding camera/performance needs."))))

(defrule category-buy-new
   (final-decision (decision buy-new))
   (phone-user (budget-level ?budget))
   =>
   (if (eq ?budget low) then
      (assert (phone-category-suggestion
         (category budget-upgrade)
         (rule-id C-BUDGET-UPGRADE)
         (message "Suggested category: budget or certified refurbished upgrade path."))))
   (if (eq ?budget medium) then
      (assert (phone-category-suggestion
         (category mid-range)
         (rule-id C-MID-UPGRADE)
         (message "Suggested category: reliable mid-range or refurbished premium upgrade path."))))
   (if (eq ?budget high) then
      (assert (phone-category-suggestion
         (category premium-or-flagship)
         (rule-id C-PREMIUM-UPGRADE)
         (message "Suggested category: premium/flagship replacement matched to workload and feature needs.")))))

(defrule final-decision-wait
   (declare (salience -107))
   (not (final-decision))
   (recommendation-cf
      (rule-id WAIT-CF)
      (certainty ?wait&:(>= ?wait 0.70)))
   =>
   (assert (final-decision
      (decision wait)
      (rule-id FINAL-WAIT)
      (message "Final decision: wait before buying.")
      (certainty ?wait))))

(defrule final-decision-fallback
   (declare (salience -108))
   (not (final-decision))
   (recommendation (rule-id R20|R25))
   =>
   (assert (final-decision
      (decision keep-current)
      (rule-id FINAL-FALLBACK)
      (message "Final decision: keep your current phone for now.")
      (certainty 0.60))))

; Model suggestions (gated and limited)
(defrule model-flagship-camera-from-data
   (final-decision (decision buy-flagship|buy-new))
   (test (< (count-model-suggestions M1) 3))
   (market-phone
      (source smartprix)
      (segment flagship)
      (camera-mp ?cam&:(>= ?cam 150.0))
      (price-cad ?price-cad&:(<= ?price-cad 1900.0))
      (model ?model)
      (spec-score ?spec&:(>= ?spec 85.0)))
   =>
   (assert (phone-model-suggestion
      (rule-id M1)
      (model ?model)
      (reason (str-cat "Flagship camera candidate from market data (approx CAD "
                       (round ?price-cad)
                       ", spec " ?spec ").")))))

(defrule model-midrange-value-from-data
   (final-decision (decision buy-mid-range|buy-new))
   (phone-user (budget-level medium))
   (test (< (count-model-suggestions M4) 3))
   (market-phone
      (source smartprix)
      (segment mid-range)
      (value-score ?vfm&:(>= ?vfm 2.25))
      (price-cad ?price-cad&:(<= ?price-cad 335.0))
      (model ?model))
   =>
   (assert (phone-model-suggestion
      (rule-id M4)
      (model ?model)
      (reason (str-cat "High-value mid-range candidate from market data (approx CAD "
                       (round ?price-cad) ").")))))

(defrule model-budget-from-data
   (final-decision (decision buy-refurbished|buy-mid-range|buy-new))
   (phone-user (budget-level low))
   (test (< (count-model-suggestions M6) 3))
   (market-phone
      (source smartprix)
      (segment budget)
      (price-cad ?price-cad&:(<= ?price-cad 180.0))
      (value-score ?vfm&:(>= ?vfm 1.7))
      (model ?model))
   =>
   (assert (phone-model-suggestion
      (rule-id M6)
      (model ?model)
      (reason (str-cat "Budget-friendly option from market data (approx CAD "
                       (round ?price-cad) ").")))))

(defrule model-refurb-estimate-from-market
   (final-decision (decision buy-refurbished))
   (phone-user (used-phone-comfort yes|maybe))
   (test (< (count-model-suggestions M8) 3))
   (market-phone
      (source smartprix)
      (segment flagship|premium)
      (spec-score ?spec&:(>= ?spec 88.0))
      (price-cad ?price-cad&:(<= ?price-cad 1500.0))
      (model ?model))
   =>
   (bind ?estimated (round (* ?price-cad 0.70)))
   (assert (phone-model-suggestion
      (rule-id M8)
      (model (str-cat "Certified Refurbished " ?model))
      (reason (str-cat "Estimated refurbished value from market price approx CAD "
                       (round ?price-cad) " is around CAD " ?estimated ".")))))

(defrule model-wait-watchlist-from-data
   (final-decision (decision wait))
   (test (< (count-model-suggestions M10) 3))
   (market-phone
      (source smartprix)
      (segment flagship)
      (spec-score ?spec&:(>= ?spec 90.0))
      (model ?model)
      (price-cad ?price-cad))
   =>
   (assert (phone-model-suggestion
      (rule-id M10)
      (model (str-cat "Watchlist: " ?model))
      (reason (str-cat "Low-upgrade-pressure profile: monitor this model for discounts (approx CAD "
                       (round ?price-cad) ").")))))

(deffunction print-results ()
   (printout t crlf "==============================" crlf)
   (printout t "PHONE PURCHASE DECISION RESULT" crlf)
   (printout t "==============================" crlf crlf)

   (printout t "Final Decision:" crlf)
   (bind ?decision-count 0)
   (do-for-all-facts ((?d final-decision)) TRUE
      (bind ?decision-count (+ ?decision-count 1))
      (printout t "- [" ?d:rule-id "] " ?d:message " Certainty: " ?d:certainty crlf))
   (if (= ?decision-count 0) then
      (printout t "- No single final decision generated." crlf))

   (printout t crlf "Key Findings:" crlf)
   (bind ?finding-count 0)
   (do-for-all-facts ((?f finding)) TRUE
      (bind ?finding-count (+ ?finding-count 1))
      (printout t "- [" ?f:rule-id "] " ?f:message crlf))
   (if (= ?finding-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf "Supporting Recommendations:" crlf)
   (bind ?rec-count 0)
   (do-for-all-facts ((?r recommendation)) TRUE
      (bind ?rec-count (+ ?rec-count 1))
      (printout t "- [" ?r:rule-id "] " ?r:message crlf))
   (if (= ?rec-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf "Confidence-Based Recommendations:" crlf)
   (bind ?cf-count 0)
   (do-for-all-facts ((?r recommendation-cf)) TRUE
      (bind ?cf-count (+ ?cf-count 1))
      (printout t "- [" ?r:rule-id "] " ?r:message " Certainty: " ?r:certainty crlf))
   (if (= ?cf-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf "Warnings:" crlf)
   (bind ?warn-count 0)
   (do-for-all-facts ((?w warning)) TRUE
      (bind ?warn-count (+ ?warn-count 1))
      (printout t "- [" ?w:rule-id "] " ?w:message crlf))
   (if (= ?warn-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf "Suggested Phone Category:" crlf)
   (bind ?cat-count 0)
   (do-for-all-facts ((?c phone-category-suggestion)) TRUE
      (bind ?cat-count (+ ?cat-count 1))
      (printout t "- [" ?c:rule-id "] " ?c:message crlf))
   (if (= ?cat-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf "Suggested Phone Models:" crlf)
   (bind ?model-count 0)
   (do-for-all-facts ((?m phone-model-suggestion)) TRUE
      (bind ?model-count (+ ?model-count 1))
      (printout t "- [" ?m:rule-id "] " ?m:model " -- " ?m:reason crlf))
   (if (= ?model-count 0) then
      (printout t "- None generated." crlf))

   (printout t crlf))
