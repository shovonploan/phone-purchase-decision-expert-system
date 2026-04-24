(deftemplate phone-user
   (slot phone-age
      (allowed-values new moderate old very-old))
   (slot battery-health
      (allowed-values good moderate poor very-poor))
   (slot performance
      (allowed-values fast acceptable slow very-slow))
   (slot storage-status
      (allowed-values enough almost-full full))
   (slot physical-condition
      (allowed-values good minor-damage major-damage broken))
   (slot software-support
      (allowed-values supported limited unsupported))
   (slot platform
      (allowed-values ios android other))
   (slot repair-cost-level
      (allowed-values low medium high very-high))
   (slot budget-cad
      (type INTEGER)
      (range 0 20000))
   (slot budget-level
      (allowed-values low medium high))
   (slot urgency
      (allowed-values low medium high))
   (slot camera-need
      (allowed-values low medium high))
   (slot gaming-need
      (allowed-values low medium high))
   (slot work-study-dependence
      (allowed-values low medium high))
   (slot latest-model-importance
      (allowed-values low medium high))
   (slot used-phone-comfort
      (allowed-values yes no maybe))
   (slot trade-in-available
      (allowed-values yes no))
   (slot battery-health-percent
      (type INTEGER)
      (range 0 100))
   (slot battery-score
      (type INTEGER)
      (range 0 100))
   (slot performance-score
      (type INTEGER)
      (range 0 100))
   (slot budget-score
      (type INTEGER)
      (range 0 100))
   (slot urgency-score
      (type INTEGER)
      (range 0 100))
   (slot repair-cost-percent
      (type INTEGER)
      (range 0 100)))

(deftemplate recommendation
   (slot rule-id)
   (slot message))

(deftemplate finding
   (slot rule-id)
   (slot message))

(deftemplate warning
   (slot rule-id)
   (slot message))

(deftemplate replacement-needed
   (slot reason)
   (slot strength
      (allowed-values low medium high)))

(deftemplate no-upgrade-needed
   (slot reason))

(deftemplate final-decision
   (slot decision)
   (slot rule-id)
   (slot message)
   (slot certainty
      (type FLOAT)
      (range 0.0 1.0)))

(deftemplate advice-category-fired
   (slot category))

(deftemplate recommendation-cf
   (slot rule-id)
   (slot message)
   (slot certainty
      (type FLOAT)
      (range 0.0 1.0)))

(deftemplate phone-model-suggestion
   (slot rule-id)
   (slot model)
   (slot reason))

(deftemplate phone-category-suggestion
   (slot category)
   (slot rule-id)
   (slot message))

(deftemplate market-phone
   (slot source
      (allowed-values smartprix mobile_dataset))
   (slot brand)
   (slot model)
   (slot segment
      (allowed-values budget mid-range premium flagship synthetic))
   (slot price-cad
      (type FLOAT)
      (range 0.0 50000.0))
   (slot camera-mp
      (type FLOAT)
      (range 0.0 500.0))
   (slot refresh-rate
      (type FLOAT)
      (range 0.0 500.0))
   (slot ram-gb
      (type FLOAT)
      (range 0.0 64.0))
   (slot storage-gb
      (type FLOAT)
      (range 0.0 2048.0))
   (slot spec-score
      (type FLOAT)
      (range 0.0 100.0))
   (slot value-score
      (type FLOAT)
      (range -10.0 10.0))
   (slot os))

(deffacts initial-phone-user-profile
   (phone-user
      (phone-age old)
      (battery-health poor)
      (performance slow)
      (storage-status almost-full)
      (physical-condition minor-damage)
      (software-support limited)
      (platform android)
      (repair-cost-level medium)
      (budget-cad 700)
      (budget-level medium)
      (urgency medium)
      (camera-need medium)
      (gaming-need low)
      (work-study-dependence high)
      (latest-model-importance low)
      (used-phone-comfort maybe)
      (trade-in-available yes)
      (battery-health-percent 35)
      (battery-score 35)
      (performance-score 45)
      (budget-score 60)
      (urgency-score 65)
      (repair-cost-percent 40)))
