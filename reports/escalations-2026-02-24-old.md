# Dev Escalations Report — 2026-02-24

## Ecommerce Escalations

**Issue:** YARP // Amazon products won't list due to image issues // [CLECOM-11173](https://citruslime.atlassian.net/browse/CLECOM-11173)
**Reported by:** Forelock and Load, Taunton Leisure
**Description:** Retailers are seeing 429 errors on Amazon listing images due to rate limits on media access. This is related to CLECOM-11045, and so we are monitoring after 23rd Feb release.
**Status:** Monitoring
**Fix Version:** 23rd Feb, Monitoring after

**Issue:** Logging // Noise suppression - starbuyErrors // [CLECOM-11234](https://citruslime.atlassian.net/browse/CLECOM-11234)
**Reported by:** Laura
**Description:** Jira sims to investigate causes and reduce error logging noise in eCommerce SEQ.
**Status:** TBC
**Fix Version:** TBC

**Issue:** Checkout // Handle store maintenance gracefully in SiteConfigMiddleware // [CLECOM-11244](https://citruslime.atlassian.net/browse/CLECOM-11244)
**Reported by:** Laura
**Description:** Raised to improve our logging for expected maintenances of ecommerce sites.
**Status:** TBC
**Fix Version:** Checkout PCI Hotpatch - date TBC

**Issue:** Checkout // Downgrade express payment validation failure from Error to Warning // [CLECOM-11241](https://citruslime.atlassian.net/browse/CLECOM-11241)
**Reported by:** Laura
**Description:** These represent incomplete ApplePay express checkout addresses (e.g. 'Last Name is required'). We want to keep the log but reduce to warning to cut error noise.
**Status:** TBC
**Fix Version:** Checkout PCI Hotpatch - date TBC

**Issue:** Checkout // Click and Collect store address occasionally being wiped // [CLECOM-11170](https://citruslime.atlassian.net/browse/CLECOM-11170)
**Reported by:** Laura - 10 examples recently
**Description:** Original Jira CLECOM-11219, but the attached Jira should sort it and other scenarios. There have been 11 examples in the last month, each causing spam in logging and requiring manual intervention.
**Status:** TBC
**Fix Version:** Checkout - March 18th

**Issue:** Checkout // Handle missing bounds in Google Geocoding response // [CLECOM-11245](https://citruslime.atlassian.net/browse/CLECOM-11245)
**Reported by:** Laura
**Description:** Errors caused by meaningless user input when searching for invalid postcode/town in click and collect. Our code requires an optional field that Google doesn't always return. Fix improves UX and error logging.
**Status:** TBC
**Fix Version:** Checkout PCI Hotpatch - date TBC

**Issue:** YARP // Improve SQL Injection attack protection // [CLECOM-11246](https://citruslime.atlassian.net/browse/CLECOM-11246)
**Reported by:** Laura & Kev
**Description:** We have various layers of SQL Injection protection (YARP, CloudFlare, IIS) but we observed some attacks managing to reach the IIS server for a standard site. This Jira aims to improve protection before that stage.
**Status:** TBC
**Fix Version:** Yarp - March

**Issue:** Pending Payments in CloudMT // [CLECOM-11178](https://citruslime.atlassian.net/browse/CLECOM-11178)
**Reported by:** Pete's Garage, Toms Pro Bike, Arcadian
**Description:** We have identified several causes of this. All are now resolved, other than one display bug in Payments which we suspect is a minor percentage. Monitoring continues to ensure there are no other scenarios.
**Status:** Monitoring
**Fix Version:** Monitoring

**Issue:** Checkout // Billing Client is being blocked // [CLECOM-11186](https://citruslime.atlassian.net/browse/CLECOM-11186)
**Reported by:** Laura
**Description:** Spotted when I returned from DK. We have recuperated the logs to prevent revenue loss. Caused by a checkout update, now resolved.
**Status:** Done
**Fix Version:** Checkout 10th February 2026

**Issue:** Logging // Downgrade Missing DNSName in Yarp Logs // [CLECOM-11231](https://citruslime.atlassian.net/browse/CLECOM-11231)
**Reported by:** Laura
**Description:** Reducing error log noise - a missing domain in a request means it can't complete. Calum has a Jira to downgrade the logs to a warning and investigate.
**Status:** TBC
**Fix Version:** TBC

**Issue:** Checkout // Add Retries before error when getting store config // [CLECOM-11221](https://citruslime.atlassian.net/browse/CLECOM-11221)
**Reported by:** Laura
**Description:** Aims to reduce logging noise for transient issues. Adding a retry means it should succeed, and only lasting (3+ tries) issues will be logged.
**Status:** TBC
**Fix Version:** Checkout 18th March 2026

**Issue:** Yarp // CSP Violations - stats.g.doubleclick.net // [CLECOM-11191](https://citruslime.atlassian.net/browse/CLECOM-11191)
**Reported by:** Laura
**Description:** Spotted in logging when I returned from DK. Caused by a Yarp update on 27th, now resolved. We do not believe this caused any issues, but sorted it as a precaution.
**Status:** Done
**Fix Version:** Yarp 11th February 2026

**Issue:** CitrusStore // Products timing out due to inefficient SQL // [CLECOM-11242](https://citruslime.atlassian.net/browse/CLECOM-11242)
**Reported by:** Cycle Solutions (now resolved for them)
**Description:** Inefficient SQL query results in timeouts on some items in CitrusStore, happening around 250 times/day platform wide. Calum investigated, we solved the issue for CSOL, and we will improve the SQL to eliminate this issue.
**Status:** TBC
**Fix Version:** 18th March 2026

**Issue:** Cloud MT // Activation date not set correctly when products are activated via Scheduled Activation // [CLECOM-11224](https://citruslime.atlassian.net/browse/CLECOM-11224)
**Reported by:** Redpost
**Description:** Using scheduled activation to activate products does not respect 'Newest in stock products first' FAF ordering. We will fix this in the attached Jira.
**Status:** TBC
**Fix Version:** 18th March 2026

**Issue:** Checkout // Adyen delivery address fails when street field is empty // [CLECOM-11195](https://citruslime.atlassian.net/browse/CLECOM-11195)
**Reported by:** Laura and Oli
**Description:** Uncovered by Oli as part of our Pending Payments investigation. This was introduced in the eCommerce January release, now resolved.
**Status:** Done
**Fix Version:** Checkout 12th February 2026

## Cloud POS Escalations

**Issue:** Back Office // Prevent items from being removed from a transfer which is in transit // [CLOUDPOS-11944](https://citruslime.atlassian.net/browse/CLOUDPOS-11944)
**Reported by:** Fully Charged, Chevin Cycles
**Description:** Retailers can delete items off a transfer which is in transit. This means units disappear without an audit trail, and serial numbers can become permanently stuck. We do not allow transfers to be deleted when in transit, so we are going to introduce the same restriction on removing items.
**Status:** TBC
**Fix Version:** TBC

**Issue:** Back Office // Purchase Orders - carry Forward Order and Ignore from PO Calculations settings onto Child POs // [CLOUDPOS-11945](https://citruslime.atlassian.net/browse/CLOUDPOS-11945)
**Reported by:** Studio Velo
**Description:** Will and I agreed it was a good move to carry over Forward Order / Ignore from calculations settings from parent to child PO. This means retailers won't have to remember to tick the boxes again for POs carried over multiple deliveries.
**Status:** TBC
**Fix Version:** TBC

**Issue:** QBP ePO Passwords Query
**Reported by:** Family Cycle Works
**Description:** We historically validate that password is exactly 8 characters long, as requested by QBP. They are now providing longer passwords, so we can't set up FWCS on ePOs. Waiting on feedback from QBP to confirm their new guidance.
**Status:** Awaiting feedback
**Fix Version:** Awaiting feedback from QBP

**Issue:** Invoice Number on Child POs query from Sheppards
**Reported by:** Sheppards Australia
**Description:** Sheppards want us to remove the pulling over of Invoice Number and Freight charges from child POs. We need to make sure this won't negatively impact other retailers. Will is going to discuss with Suzy.
**Status:** Awaiting discussion
**Fix Version:** Awaiting internal discussion

**Issue:** BMBI Dates appearing inconsistently
**Reported by:** Greenaer
**Description:** BMBI next available date shows differently in Workshop vs in BMBI. Will investigated — we believe this is related to store vs workshop opening hours.
**Status:** Investigating
**Fix Version:** TBC - Will investigating

**Issue:** Store Default Tax for US Retailers in Purchase Orders
**Reported by:** Garage Bike and Brews
**Description:** GRGE are querying how PO tax works. Previously set up with the wrong tax type (inclusive vs exclusive), which had to be sorted via manual amendment. Debbie C and Will are unpacking whether the platform is now working as intended.
**Status:** Investigating
**Fix Version:** TBC - Will & Debbie C investigating. Wizard has been run to sort for retailer in the meantime.

## DevOps Escalations

**Issue:** Outages to WEB28 - 18th, 19th, 20th February
**Reported by:** Laura
**Description:** Kevin and I have been investigating this whilst Max has been working on PCI. The incidents are short but recurrent, for a small number of sites. Yarp marks them as unhealthy and a maintenance page is shown. Kevin is continuing his work on this.
**Status:** Investigating
**Fix Version:** Ongoing Investigation

## Issues with no ETA on Last Report

**Issue:** Stock Take Timeouts // [CLOUDPOS-11170](https://citruslime.atlassian.net/browse/CLOUDPOS-11170)
**Reported by:** Hope Valley, Trekitt, Balfes
**Description:** If a Stock Take is for a high number of items (55,000+), it is likely to timeout at the last stage, meaning it cannot be committed. We're going to see if we can optimise the page as a first step. Retailers use big stock takes for supplier stock files and full inventory counts.
**Status:** TBC
**Fix Version:** TBC - this sprint

**Issue:** Redpost - Order Stuck due to malformed API request - Postcode had /n at the end // [CLECOM-10680](https://citruslime.atlassian.net/browse/CLECOM-10680)
**Reported by:** Laura
**Description:** We are adding a trim() for eCommerce and POS to make sure orders do not get stuck due to this problem again. POS fix will be out next week, eComm fix on the attached Jira — low priority due to low frequency.
**Status:** TBC
**Fix Version:** TBC - low priority as only happened once

**Issue:** Courier Integration Module // Mask Intersoft credentials in SEQ log // [CLOUDPOS-11290](https://citruslime.atlassian.net/browse/CLOUDPOS-11290)
**Reported by:** Laura
**Description:** I noticed, whilst looking at the RM JE/GY issue, that we are logging our Intersoft credentials in SEQ logs when there is an Intersoft error. We are going to mask these out of good practice.
**Status:** TBC
**Fix Version:** TBC

**Issue:** Adyen Payment Link refunds - reporting/payout oddities for TALE/BALF
**Reported by:** Taunton Leisure, Balfes Bikes
**Description:** Some payments show in two separate payouts — one on the initial summaries, and another when viewing payout lines. This is due to the ValueDate and the actual paid date not matching. We are in discussion with Adyen about this.
**Status:** TBC
**Fix Version:** TBC - Adyen making changes in future

**Issue:** Windsor Framework for DX // [CLOUDPOS-11627](https://citruslime.atlassian.net/browse/CLOUDPOS-11627)
**Reported by:** Balfes
**Description:** Balfes use DX for shipping bikes. We need to add support for Customs info for BT/JE/GY.
**Status:** TBC
**Fix Version:** TBC

**Issue:** Hope Valley downtime on 11/12/25 // [CLECOM-10930](https://citruslime.atlassian.net/browse/CLECOM-10930)
**Reported by:** Hope Valley
**Description:** Mailer went out, big spike in traffic and CPU. Level of traffic and fragmented indexes playing a part. More cores added, and work ongoing about fragmented indexes.
**Status:** TBC
**Fix Version:** Index Jira attached - fix version TBC

**Issue:** GA4 issues - missing revenue attribution and checkout journey reporting // [CLECOM-11055](https://citruslime.atlassian.net/browse/CLECOM-11055)
**Reported by:** Taunton Leisure, Trekitt, confirmed by DMS Team
**Description:** Ben and I had a discussion about further GA4 issues which have been raised recently by Tier 1s. We are making a plan to resolve, liaising with DMS about any other issues.
**Status:** WIP
**Fix Version:** Jira is WIP - liaising with DMS

**Issue:** Gift Vouchers // Gift Voucher expiry - POS treats as expired but Back Office shows as valid // [CLOUDPOS-11713](https://citruslime.atlassian.net/browse/CLOUDPOS-11713)
**Reported by:** Chevin Cycles
**Description:** -
**Status:** TBC
**Fix Version:** TBC

---
*Generated 2026-02-24 by Update-EscReport.ps1 (initial conversion from Excel)*
