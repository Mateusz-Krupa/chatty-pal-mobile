import SwiftUI

struct PolicyView: View {
    private let contactEmail = "info@chatty-pal.com"
    private let microsoftPrivacyURL = URL(string: "https://privacy.microsoft.com/en-GB/privacystatement")!

    private let collectionInfo = [
        "Personal Information: data you voluntarily provide when signing up, such as your name and email address.",
        "Non-personal Information: statistical data such as how you use the website, browsing habits, IP address, operating system, and browser type."
    ]

    private let collectionMethods = [
        "Direct Interactions: you may provide personal data when completing online forms, requesting services, or corresponding with us.",
        "Automated technologies or Interactions: we may automatically collect technical data using cookies, server logs, and other similar technologies."
    ]

    private let infoUse = [
        "Provide, maintain, and improve our services.",
        "Respond to your comments, questions, and requests and provide customer service.",
        "Communicate with you about products, services, offers, promotions, and events.",
        "Monitor and analyze trends, usage, and activities in connection with our services.",
        "Personalize and improve our services and provide advertisements, content or features that match user profiles or interests."
    ]

    private let userChoices = [
        "Cookies: you can set your browser to refuse all or some browser cookies, or to alert you when cookies are being sent.",
        "Opting Out of Google Analytics: you can opt out of tracking by visiting the Google Ads Settings page or by installing their opt-out browser add-on."
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Chatty Pal", systemImage: "lock.shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("Privacy Policy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Effective Date: June 13, 2023")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("This Privacy Policy explains how information about you is collected, used, and disclosed by your use of our Service. We respect your privacy and are committed to protecting it through our compliance with this policy.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ChattyTheme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ChattyTheme.softHairline, lineWidth: 1)
                )

                InfoSectionCard(title: "Information We Collect", systemImage: "tray.full") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(collectionInfo, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "Purpose of Collection", systemImage: "target") {
                    Text("We collect and store your name and email address solely to facilitate your access to our application. We also collect and store information related to your homework and exercises performed within the app. This data is used to fine-tune our conversational models, improving the user experience and the app's performance over time.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Information Sharing and Disclosure", systemImage: "arrowshape.turn.up.right") {
                    Text("We may share information pertaining to your homework and exercises with third parties for analytical and development purposes. Your personal information, including your name and email address, will not be shared with third parties. Within the app, your name and email address will only be visible to the teacher or school when you are added to a class.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Data Retention", systemImage: "clock") {
                    Text("We retain information related to your homework and exercises for a period of one year from the date of creation. This retention policy helps us maintain a relevant and efficient service, ensuring our conversational models remain up-to-date and effective.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "How We Collect Information", systemImage: "magnifyingglass") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(collectionMethods, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "Use of Google Analytics", systemImage: "chart.bar") {
                    Text("Our website uses Google Analytics, a web analytics service provided by Google. Google Analytics uses cookies to help analyze how users use the site. The information generated by the cookie about your use of the website (including your IP address) will be transmitted to and stored by Google on servers in the United States.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Use of AI Technologies", systemImage: "cpu") {
                    Text("Our service utilizes advanced AI technologies including OpenAI's GPT, Google AI Tools and Fixi AI to provide some of its core functionalities. These AI technologies help us understand and interpret your queries and requests, provide responses, and offer personalized experiences.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Gathering Homework Information for Teachers", systemImage: "person.text.rectangle") {
                    Text("If you are a student of a school, we may gather information from your homework interactions with our chat. This information is solely for the purpose of providing the teacher with the necessary data to review your progress and performance. This information is securely stored and only accessible to authorized personnel for educational purposes.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "How We Use Your Information", systemImage: "list.bullet.rectangle") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(infoUse, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                        Text("We partner with Microsoft Clarity and Microsoft Advertising to capture how you use and interact with our website through behavioral metrics, heatmaps, and session replay to improve and market our products/services. Website usage data is captured using first and third-party cookies and other tracking technologies. For more information about how Microsoft collects and uses your data, visit the")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: microsoftPrivacyURL) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                Text("Microsoft Privacy Statement")
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }

                InfoSectionCard(title: "Your Choices", systemImage: "slider.horizontal.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(userChoices, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "User Rights", systemImage: "person.crop.circle.badge.checkmark") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You have the right to delete your profile from our platform at any time. Upon deletion, your identity will be disassociated from the homework and exercise data; however, the data itself will not be deleted. On special request, we can also remove all the data you have created.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Text("Note: data used to fine-tune our model will not be removed, although we will delete all your conversation records from our database. To process this, you will need to send us an email from the email address associated with your account, detailing your request.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text(contactEmail)
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }

                InfoSectionCard(title: "Changes to this Policy", systemImage: "clock.arrow.circlepath") {
                    Text("We may update our privacy policy from time to time. You are advised to review this page periodically for any changes. We will notify you by email of any changes by posting the new privacy policy on this page. These changes are effective immediately after they are posted.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Contact Us", systemImage: "envelope") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text(contactEmail)
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Learning Materials
