# Dev Escalations Report — 2026-02-25

## Ecommerce Escalations

**Issue:** YARP // Amazon products won't list due to image issues // [CLECOM-11173](https://citruslime.atlassian.net/browse/CLECOM-11173)
**Reported by:** Forelock and Load, Taunton Leisure
**Description:** Retailers are seeing 429 errors on Amazon listing images due to rate limits on media access. This is related to CLECOM-11045, and so we are monitoring after 23rd Feb release.
**Fix Version:** YARP - March 2026

**Issue:** CitrusStore // Logging // Noise suppression - starbuyErrors // [CLECOM-11234](https://citruslime.atlassian.net/browse/CLECOM-11234)
**Reported by:** Laura
**Description:** Jira sims to investigate causes and reduce error logging noise in eCommerce SEQ.
**Fix Version:** Ecommerce Main - 18th March 2026 - Major Release (2026-03-18)

**Issue:** Checkout // Handle store maintenance gracefully in SiteConfigMiddleware // [CLECOM-11244](https://citruslime.atlassian.net/browse/CLECOM-11244)
**Reported by:** Laura
**Description:** Raised to improve our logging for expected maintenances of ecommerce sites.
**Fix Version:** Checkout - PCI Hotpatch

**Issue:** Checkout // Downgrade express payment validation failure from Error to Warning // [CLECOM-11241](https://citruslime.atlassian.net/browse/CLECOM-11241)
**Reported by:** Laura
**Description:** These represent incomplete ApplePay express checkout addresses (e.g. 'Last Name is required'). We want to keep the log but reduce to warning to cut error noise.
**Fix Version:** Checkout - PCI Hotpatch

**Issue:** Checkout // Handle missing bounds in Google Geocoding response // [CLECOM-11245](https://citruslime.atlassian.net/browse/CLECOM-11245)
**Reported by:** Laura
**Description:** Errors caused by meaningless user input when searching for invalid postcode/town in click and collect. Our code requires an optional field that Google doesn't always return. Fix improves UX and error logging.
**Fix Version:** Checkout - PCI Hotpatch

**Issue:** Cloud MT //  Adyen Pending Payments // [CLECOM-11178](https://citruslime.atlassian.net/browse/CLECOM-11178)
**Reported by:** Pete's Garage, Toms Pro Bike, Arcadian
**Description:** We have identified several causes of this. All are now resolved, other than one display bug in Payments which we suspect is a minor percentage. Monitoring continues to ensure there are no other scenarios.
**Fix Version:** Cloud MT - 18th March 2026 - Major Release (2026-03-18)

**Issue:** Logging // Downgrade Missing DNSName in Yarp Logs // [CLECOM-11231](https://citruslime.atlassian.net/browse/CLECOM-11231)
**Reported by:** Laura
**Description:** Reducing error log noise - a missing domain in a request means it can't complete. Calum has a Jira to downgrade the logs to a warning and investigate.
**Fix Version:** TBC

**Issue:** Omnisend // Add Product Vendor to Order Fulfilled & add Product Activity to Order Placed / Order Fulfilled // [CLECOM-11268](https://citruslime.atlassian.net/browse/CLECOM-11268)
**Reported by:** Laura Foster
**Description:** Why? What? Example section of an Order Fulfilled from Omnisend BEFORE change: {
  "createdAt": "2025-12-14T15:06:02Z",
  "currency": "GBP",
  "fulfillmentStatus": "fulfilled",
  "lineItems": [
  ...
**Fix Version:** TBC

**Issue:** Checkout // V12 Orders Never Complete - Status 409 // [CLECOM-11260](https://citruslime.atlassian.net/browse/CLECOM-11260)
**Reported by:** Laura Foster
**Description:** Why? What? We are seeing Status 409 for V12 Order finalisations. The ‘ReturnURL’ for V12 is set per site, and it [site] /checkout/api/v12/confirm?REF= [FinanceApplicationId]. We can use Yarp’s HTTP lo...
**Fix Version:** Checkout - 24th February 2026 (2026-02-26)

**Issue:** Yarp // Csp Violation Cleanup - February 2026 // [CLECOM-11256](https://citruslime.atlassian.net/browse/CLECOM-11256)
**Reported by:** Laura Foster
**Description:** Why? Alongside daily monitoring for security and stability, we have agreed to clean up CSP violations for non-urgent blocks every month. This aims to keep logging clean and make it easier to spot fals...
**Fix Version:** TBC

**Issue:** CitrusStore // Products timing out due to inefficient SQL // [CLECOM-11242](https://citruslime.atlassian.net/browse/CLECOM-11242)
**Reported by:** Laura Foster
**Description:** Why? What? Example error:    Filter to show other examples:    Improve the SQL which is timing out. How? The offending SQL query appears in  ProductPageServiceDataLoaderDirectDb.vb This LINQ results i...
**Fix Version:** Checkout - 18th March 2026 - Major Release (2026-03-18)

**Issue:** Monitoring // Introduce Post-Hotpatch Monitoring Procedure for Release Owner // [CLECOM-11240](https://citruslime.atlassian.net/browse/CLECOM-11240)
**Reported by:** Laura Foster
**Description:** Why? What?
**Fix Version:** TBC

## Cloud POS Escalations

**Issue:** Back Office // Prevent items from being removed from a transfer which is in transit // [CLOUDPOS-11944](https://citruslime.atlassian.net/browse/CLOUDPOS-11944)
**Reported by:** Fully Charged, Chevin Cycles
**Description:** Retailers can delete items off a transfer which is in transit. This means units disappear without an audit trail, and serial numbers can become permanently stuck. We do not allow transfers to be deleted when in transit, so we are going to introduce the same restriction on removing items.
**Fix Version:** TBC

**Issue:** Back Office // Purchase Orders - carry Forward Order and Ignore from PO Calculations settings onto Child POs // [CLOUDPOS-11945](https://citruslime.atlassian.net/browse/CLOUDPOS-11945)
**Reported by:** Studio Velo
**Description:** Will and I agreed it was a good move to carry over Forward Order / Ignore from calculations settings from parent to child PO. This means retailers won't have to remember to tick the boxes again for POs carried over multiple deliveries.
**Fix Version:** TBC

**Issue:** QBP ePO Passwords Query
**Reported by:** Family Cycle Works
**Description:** We historically validate that password is exactly 8 characters long, as requested by QBP. They are now providing longer passwords, so we can't set up FWCS on ePOs. Waiting on feedback from QBP to confirm their new guidance.
**Fix Version:** Awaiting feedback from QBP

**Issue:** Invoice Number on Child POs query from Sheppards
**Reported by:** Sheppards Australia
**Description:** Sheppards want us to remove the pulling over of Invoice Number and Freight charges from child POs. We need to make sure this won't negatively impact other retailers. Will is going to discuss with Suzy.
**Fix Version:** Awaiting internal discussion

**Issue:** BMBI Dates appearing inconsistently
**Reported by:** Greenaer
**Description:** BMBI next available date shows differently in Workshop vs in BMBI. Will investigated — we believe this is related to store vs workshop opening hours.
**Fix Version:** TBC - Will investigating

**Issue:** Store Default Tax for US Retailers in Purchase Orders
**Reported by:** Garage Bike and Brews
**Description:** GRGE are querying how PO tax works. Previously set up with the wrong tax type (inclusive vs exclusive), which had to be sorted via manual amendment. Debbie C and Will are unpacking whether the platform is now working as intended.
**Fix Version:** TBC - Will & Debbie C investigating. Wizard has been run to sort for retailer in the meantime.

**Issue:** Adyen // Webhooks Occasionally Fail - Connection Timeout // [CLOUDPOS-11953](https://citruslime.atlassian.net/browse/CLOUDPOS-11953)
**Reported by:** Laura Foster
**Description:** Why? What? Adyen webhooks are occasionally failing with the error: Connection timed out while connecting to the configured endpoint. Example instance:   We can see the following error in SEQ:   How? W...
**Fix Version:** Cloud POS April 2026 (2026-04-07)

## DevOps Escalations

**Issue:** Outages to WEB28 - 18th, 19th, 20th February
**Reported by:** Laura
**Description:** Kevin and I have been investigating this whilst Max has been working on PCI. The incidents are short but recurrent, for a small number of sites. Yarp marks them as unhealthy and a maintenance page is shown. Kevin is continuing his work on this.
**Fix Version:** Ongoing Investigation

**Issue:** Investigation // Yarp Marking Websites as Unhealthy - during Backup? // [DEVOP-2211](https://citruslime.atlassian.net/browse/DEVOP-2211)
**Reported by:** Laura Foster
**Description:** Why? What? Attached spreadsheet shows examples of Yarp marking sites as unhealthy through the night. The same data can be obtained using the following Axiom query: ['ecommerce-yarp-application-logs-pr...
**Fix Version:** TBC

## Issues with no ETA on Last Report

**Issue:** Back Office // Timeouts when trying to commit large stock takes // [CLOUDPOS-11170](https://citruslime.atlassian.net/browse/CLOUDPOS-11170)
**Reported by:** Hope Valley, Trekitt, Balfes
**Description:** If a Stock Take is for a high number of items (55,000+), it is likely to timeout at the last stage, meaning it cannot be committed. We're going to see if we can optimise the page as a first step. Retailers use big stock takes for supplier stock files and full inventory counts.
**Fix Version:** TBC

**Issue:** Checkout // Sanitize Postcode, FirstName, LastName, Email Address and MobileNumber in backend  // [CLECOM-10680](https://citruslime.atlassian.net/browse/CLECOM-10680)
**Reported by:** Laura
**Description:** We are adding a trim() for eCommerce and POS to make sure orders do not get stuck due to this problem again. POS fix will be out next week, eComm fix on the attached Jira — low priority due to low frequency.
**Fix Version:** TBC

**Issue:** Courier Module // Mask Intersoft credentials in SEQ log // [CLOUDPOS-11290](https://citruslime.atlassian.net/browse/CLOUDPOS-11290)
**Reported by:** Laura
**Description:** I noticed, whilst looking at the RM JE/GY issue, that we are logging our Intersoft credentials in SEQ logs when there is an Intersoft error. We are going to mask these out of good practice.
**Fix Version:** TBC

**Issue:** Adyen Payment Link refunds - reporting/payout oddities for TALE/BALF
**Reported by:** Taunton Leisure, Balfes Bikes
**Description:** Some payments show in two separate payouts — one on the initial summaries, and another when viewing payout lines. This is due to the ValueDate and the actual paid date not matching. We are in discussion with Adyen about this.
**Fix Version:** TBC - Adyen making changes in future

**Issue:** Courier Integration // DX Freight - BT customs for Windsor Framework // [CLOUDPOS-11627](https://citruslime.atlassian.net/browse/CLOUDPOS-11627)
**Reported by:** Balfes
**Description:** Balfes use DX for shipping bikes. We need to add support for Customs info for BT/JE/GY.
**Fix Version:** TBC

**Issue:** CitrusStore // Rebuild all SQL indexes nightly - Hangfire Job // [CLECOM-10930](https://citruslime.atlassian.net/browse/CLECOM-10930)
**Reported by:** Hope Valley
**Description:** Mailer went out, big spike in traffic and CPU. Level of traffic and fragmented indexes playing a part. More cores added, and work ongoing about fragmented indexes.
**Fix Version:** TBC

**Issue:** Checkout (?) // GA4 Issues - January 2026 // [CLECOM-11055](https://citruslime.atlassian.net/browse/CLECOM-11055)
**Reported by:** Taunton Leisure, Trekitt, confirmed by DMS Team
**Description:** Ben and I had a discussion about further GA4 issues which have been raised recently by Tier 1s. We are making a plan to resolve, liaising with DMS about any other issues.
**Fix Version:** TBC

**Issue:** Gift Vouchers // Gift Voucher expiry - POS treats as expired but Back Office shows as valid // [CLOUDPOS-11713](https://citruslime.atlassian.net/browse/CLOUDPOS-11713)
**Reported by:** Chevin Cycles
**Description:** Why? What? Replication Steps: LOOM to illustrate:    How?
**Fix Version:** TBC

---
*Generated 2026-02-25 11:45 by Update-EscReport.ps1*
