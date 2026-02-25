# Dev Escalations Report — 2026-02-25

## Ecommerce Escalations

| Title | Description | Fix Version | Jira Key |
|-------|-------------|-------------|----------|
| Logging // Downgrade Missing DNSName in Yarp Logs | Reducing error log noise - a missing domain in a request means it can't complete. Calum has a Jira to downgrade the logs to a warning and investigate. | TBC | [CLECOM-11231](https://citruslime.atlassian.net/browse/CLECOM-11231) |
| Yarp // Csp Violation Cleanup - February 2026 | Alongside daily monitoring for security and stability, we have agreed to clean up CSP violations for non-urgent blocks every month. This aims to keep logging clean and make it easier to spot false blocks. | TBC | [CLECOM-11256](https://citruslime.atlassian.net/browse/CLECOM-11256) |
| Checkout // V12 Orders Never Complete - Status 409 | We were seeing Status 409 for V12 Order finalisations. This was caused by introduction of middleware which validates the confirm page with cookies. If the user finishes their V12 order on a differenct device or browser, this meant the V12 application would never download as an order when finished. | Checkout - 24th February 2026 (2026-02-26) | [CLECOM-11260](https://citruslime.atlassian.net/browse/CLECOM-11260) |
| CitrusStore // Products timing out due to inefficient SQL | This was reported by CSOL, who had a product timing out on their website. Investigation into the cause revealed that the timeout is data-driven, but linked to an inefficient SQL query which produces a very large number of rows. This error is occurring for multiple items, across multiple sites, not just this item for CSOL. NB, we have resolved this item for them by removing duff FAQ submissions. This error occurs 200-300 times/day and prevents customers from purchasing an affected product. | Checkout - 18th March 2026 - Major Release (2026-03-18) | [CLECOM-11242](https://citruslime.atlassian.net/browse/CLECOM-11242) |
| Omnisend // Add Product Vendor to Order Fulfilled & add Product Activity to Order Placed / Order Fulfilled | Why? What? Example section of an Order Fulfilled from Omnisend BEFORE change: {
  "createdAt": "2025-12-14T15:06:02Z",
  "currency": "GBP",
  "fulfillmentStatus": "fulfilled",
  "lineItems": [
  ... | TBC | [CLECOM-11268](https://citruslime.atlassian.net/browse/CLECOM-11268) |
| Monitoring // Introduce Post-Hotpatch Monitoring Procedure for Release Owner | Why? What? | TBC | [CLECOM-11240](https://citruslime.atlassian.net/browse/CLECOM-11240) |

## Cloud POS Escalations

| Title | Description | Fix Version | Jira Key |
|-------|-------------|-------------|----------|
| Back Office // Prevent items from being removed from a transfer which is in transit | Retailers can delete items off a transfer which is in transit. This means units disappear without an audit trail, and serial numbers can become permanently stuck. We do not allow transfers to be deleted when in transit, so we are going to introduce the same restriction on removing items. | TBC | [CLOUDPOS-11944](https://citruslime.atlassian.net/browse/CLOUDPOS-11944) |
| Back Office // Purchase Orders - carry Forward Order and Ignore from PO Calculations settings onto Child POs | Will and I agreed it was a good move to carry over Forward Order / Ignore from calculations settings from parent to child PO. This means retailers won't have to remember to tick the boxes again for POs carried over multiple deliveries. | TBC | [CLOUDPOS-11945](https://citruslime.atlassian.net/browse/CLOUDPOS-11945) |
| QBP ePO Passwords Query | We historically validate that password is exactly 8 characters long, as requested by QBP. They are now providing longer passwords, so we can't set up FWCS on ePOs. Waiting on feedback from QBP to confirm their new guidance. | Awaiting feedback from QBP | - |
| Invoice Number on Child POs query from Sheppards | Sheppards want us to remove the pulling over of Invoice Number and Freight charges from child POs. We need to make sure this won't negatively impact other retailers. Will is going to discuss with Suzy. | Awaiting internal discussion | - |
| BMBI // Ensure consistent use of workshop hours vs. store hours for determining available drop off dates | BMBI next available date shows differently in Workshop vs in BMBI. Will investigated — we believe this is related to store vs workshop opening hours. | TBC | [CLOUDPOS-11951](https://citruslime.atlassian.net/browse/CLOUDPOS-11951) |
| Store Default Tax for US Retailers in Purchase Orders | GRGE are querying how PO tax works. Previously set up with the wrong tax type (inclusive vs exclusive), which had to be sorted via manual amendment. Debbie C and Will are unpacking whether the platform is now working as intended. | TBC - Will & Debbie C investigating. Wizard has been run to sort for retailer in the meantime. | - |
| Adyen // Webhooks Occasionally Fail - Connection Timeout | Adyen webhooks are occasionally failing with the error: Connection timed out while connecting to the configured endpoint. Suzy has found a SEQ error which appears related, this Jira aims to resolve. | Cloud POS April 2026 (2026-04-07) | [CLOUDPOS-11953](https://citruslime.atlassian.net/browse/CLOUDPOS-11953) |

## DevOps Escalations

| Title | Description | Fix Version | Jira Key |
|-------|-------------|-------------|----------|
| Outages to WEB28 - 18th, 19th, 20th February | Kevin, Neil and I looked into this. The incidents are short but recurrent, for a small number of sites. Yarp marks them as unhealthy and a maintenance page is shown. We have taken immediate steps to resolve, and are currently monitoring. Things look good so far. | Monitoring after reboots | - |
| Investigation // Yarp Marking Websites as Unhealthy - during Backup? | Kev and I spotted this during other investigation. This relates to Yarp marking some sites as unhealthy at 2am. Kev is going to look into this when he gets the chance. | TBC | [DEVOP-2211](https://citruslime.atlassian.net/browse/DEVOP-2211) |

## Issues with no ETA on Last Report

| Title | Description | Fix Version | Jira Key |
|-------|-------------|-------------|----------|
| Back Office // Timeouts when trying to commit large stock takes | If a Stock Take is for a high number of items (55,000+), it is likely to timeout at the last stage, meaning it cannot be committed. We're going to see if we can optimise the page as a first step. Retailers use big stock takes for supplier stock files and full inventory counts. | TBC | [CLOUDPOS-11170](https://citruslime.atlassian.net/browse/CLOUDPOS-11170) |
| Checkout // Sanitize Postcode, FirstName, LastName, Email Address and MobileNumber in backend  | We are adding a trim() for eCommerce and POS to make sure orders do not get stuck due to this problem again. POS fix is out, eComm fix on the attached Jira — low priority due to low frequency. | TBC | [CLECOM-10680](https://citruslime.atlassian.net/browse/CLECOM-10680) |
| Courier Module // Mask Intersoft credentials in SEQ log | I noticed, whilst looking at a different issue, that we are logging our Intersoft credentials in SEQ logs when there is an Intersoft error. We are going to mask these out of good practice. | TBC | [CLOUDPOS-11290](https://citruslime.atlassian.net/browse/CLOUDPOS-11290) |
| Adyen Payment Link refunds - reporting/payout oddities for TALE/BALF | Some payments show in two separate payouts — one on the initial summaries, and another when viewing payout lines. This is due to the ValueDate and the actual paid date not matching. We are in discussion with Adyen about this. | TBC - Adyen making changes in future | - |
| Courier Integration // DX Freight - BT customs for Windsor Framework | Balfes use DX for shipping bikes. We need to add support for Customs info for BT/JE/GY. | TBC | [CLOUDPOS-11627](https://citruslime.atlassian.net/browse/CLOUDPOS-11627) |
| CitrusStore // Rebuild all SQL indexes nightly - Hangfire Job | Mailer went out, big spike in traffic and CPU. Level of traffic and fragmented indexes playing a part. Work ongoing to publish the nightly fix for fragmented indexes. Currently, all but HOVA use the original script. | TBC | [CLECOM-10930](https://citruslime.atlassian.net/browse/CLECOM-10930) |
| Checkout (?) // GA4 Issues - January 2026 | Ben and I had a discussion about further GA4 issues which have been raised by Tier 1s. We are making a plan to resolve, liaising with DMS about any other issues. | TBC | [CLECOM-11055](https://citruslime.atlassian.net/browse/CLECOM-11055) |
| Gift Vouchers // Gift Voucher expiry - POS treats as expired but Back Office shows as valid | There is currently an issue where gift vouchers show as ‘valid’ in Back Office on their expiry date, but then cannot be redeemed on said date. Although it feels like the voucher is valid until the end of that day, the system instead treats it as expired, displaying an error such as: “This voucher has expired". Back Office shows it as valid, but POS says it’s expired. | TBC | [CLOUDPOS-11713](https://citruslime.atlassian.net/browse/CLOUDPOS-11713) |

---
*Generated 2026-02-25 13:11 by Update-EscReport.ps1*
