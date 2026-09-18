# Guideline 2.1 — App Review Response

## Before replying

Record the submitted build on a physical iPhone running the latest available iOS version. The recording should begin on the Home Screen and show the app being launched. Upload the recording as an attachment to the App Review message, then replace `[ATTACHED]` below with the actual attachment name if needed.

## Paste-ready response for Resolution Center and App Review Notes

Hello App Review Team,

Thank you for your feedback. We have tested the submitted build on a supported physical iPhone running the latest available version of iOS.

1. Physical-device screen recording

A screen recording captured on a physical iPhone is attached to this response. The recording begins with launching the app and demonstrates the typical user flow, including onboarding, adding products, choosing quantities and stock states, viewing the automatically generated shopping list, completing a shopping session, viewing purchase history, and viewing the Home Screen widget.

The app does not include account registration, login, account deletion, or user-generated content features.

2. App purpose and target audience

Market List is a personal grocery inventory and shopping-list utility intended for individuals and households. It helps users remember which everyday products are available, running low, or out of stock. Products marked as out of stock are included in the shopping list. Users can specify quantities, mark products as purchased during a shopping session, review purchase history, quickly add common products, and view the current list in a Home Screen widget.

The app solves the problem of maintaining separate mental or written lists by keeping household stock status and the current shopping list together in a simple, focused interface.

3. Accessing the main features

No account, login credentials, subscription, payment, or sample files are required.

To access the app’s main features:

- Launch the app and complete the short onboarding flow.
- Tap the plus button to create a product.
- Enter a product name, select its quantity and stock state, and save it.
- Products marked as Out automatically appear in the shopping list.
- Use Shopping Mode to mark listed products as purchased.
- Open the History tab to view completed purchases and add products again.
- Open the Home tab to view stock summaries and quickly add common products.
- To view the widget, add the Market List widget from the iOS Home Screen widget gallery. The widget displays the current shopping list.

4. External services, tools, or platforms

The app does not use any external service, backend, data provider, authentication service, payment processor, advertising network, analytics service, cloud service, or AI service.

Core functionality is implemented with Apple system frameworks, including SwiftUI, SwiftData, and WidgetKit. Product and shopping-list data is stored locally on the device. The app and widget share the current list locally through an Apple App Group container. No user data is transmitted off the device.

5. Regional differences

The app functions consistently in all regions. There are no region-specific features, restrictions, or content differences. The interface is available in Turkish and English and follows the device language setting; this localization does not change the app’s functionality.

6. Regulated services and protected third-party material

The app does not operate in a regulated industry and does not provide financial, medical, legal, gambling, transportation, or other regulated services. It does not include or provide access to protected third-party content. No authorization documents or third-party credentials are required.

We hope this information and the attached physical-device recording provide everything needed to continue the review. Please let us know if any additional information is required.

Best regards,

Talha Gergin

## Physical-device recording checklist

Keep the recording focused and approximately 1–3 minutes:

1. Delete the app from the physical iPhone, install the submitted/TestFlight build again, and enable screen recording.
2. Begin on the iPhone Home Screen so the reviewer can see that this is a physical-device flow.
3. Launch Market List and complete onboarding.
4. Add `Milk` or `Süt`, set quantity to `2`, and choose `Out / Bitti`.
5. Return to the List tab and show that the product appears with its quantity.
6. Add one or two additional products using Quick Add on the Home tab.
7. Start Shopping Mode and mark a product as purchased.
8. Open History and show the completed purchase.
9. Return to the Home Screen and show the Market List widget displaying the active shopping list.
10. Stop recording and review the entire video before attaching it. Make sure no personal notifications, Apple Account details, phone number, or other private information appear.

## App Store Connect steps

1. Open the rejected version in App Store Connect.
2. Open the App Review message in Resolution Center.
3. Attach the physical-device screen recording.
4. Paste the complete English response above and send it.
5. Open `App Review Information` for version 1.0.
6. Paste the same response into the `Notes` field. If the field length is limited, use the condensed notes below.
7. Save the version and choose `Submit for Review` or `Resubmit`, as shown by App Store Connect.

## Condensed App Review Notes

Market List is an offline grocery inventory and shopping-list app for individuals and households. No account, login, credentials, payments, subscriptions, or sample files are required. Complete onboarding, tap + to add a product, select quantity and stock state, and save. Products marked Out appear automatically in the shopping list. Shopping Mode records completed purchases in History. Home provides stock summaries and Quick Add. The optional Home Screen widget displays the current list. The app uses only Apple SwiftUI, SwiftData, WidgetKit, and an on-device App Group container. It has no backend, external APIs, authentication, ads, analytics, cloud, AI, or tracking, and transmits no user data. Functionality is identical worldwide; only Turkish/English interface localization changes with device language. The app is not regulated and contains no protected third-party content. A physical-device recording demonstrating the complete flow is attached in Resolution Center.
