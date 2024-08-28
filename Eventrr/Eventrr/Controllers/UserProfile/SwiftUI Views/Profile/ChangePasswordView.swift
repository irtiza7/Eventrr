import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    
    @Environment(\.navigationController) private var navigationController: UINavigationController?
    @ObservedObject private var viewModel = ChangePasswordViewModel()
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showSpinner = false
    
    var body: some View {
        ZStack {
            SwiftUIConstants.primaryBackgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Change Password")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)
                    .padding(.top, 40)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Email")
                            .font(.headline)
                    }
                    
                    TextField("", text: $viewModel.userEmail)
                        .padding()
                        .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                        .overlay(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius).strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0)))
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Current Password")
                            .font(.headline)
                    }
                    
                    SecureField("", text: $viewModel.currentPassword)
                        .padding()
                        .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                        .overlay(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius).strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0)))
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("New Password")
                            .font(.headline)
                    }
                    
                    SecureField("", text: $viewModel.newPassword)
                        .padding()
                        .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                        .overlay(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius).strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0)))
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.horizontal, 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Confirm Password")
                            .font(.headline)
                    }
                    
                    SecureField("", text: $viewModel.confirmPassword)
                        .padding()
                        .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                        .overlay(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius).strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0)))
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.horizontal, 10)
                
                Button(action: {
                    changePassword()
                }) {
                    Text("UPDATE")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(SwiftUIConstants.primaryAccentColor)
                        .foregroundColor(SwiftUIConstants.primaryBackgroundColor)
                        .cornerRadius(SwiftUIConstants.buttonCornerRadius)
                }
                .padding(.top, 20)
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Okay")))
            }
            
            if showSpinner {
                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .frame(width: 170, height: 50)
                        .progressViewStyle(.circular)
                        .tint(SwiftUIConstants.primaryAccentColor)
                        .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                        .padding()
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
            }
        }
    }
    
    private func changePassword() {
        showSpinner = true
        Task {
            do {
                if let errorMessage = try viewModel.validateFields() {
                    alertMessage = errorMessage
                    showAlert = true
                    return
                }
                
                if let errorMessage = try await viewModel.reauthenticateUser() {
                    alertMessage = errorMessage
                    showAlert = true
                    return
                }
                
                if let errorMessage = try await viewModel.updatePassword() {
                    alertMessage = errorMessage
                    showAlert = true
                    return
                }
                
                showSpinner = false
                navigationController?.popToRootViewController(animated: true)
            } catch let error as AuthError {
                showSpinner = false
                if error == AuthError.userNotAuthenticated {
                    navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                print("[\(String(describing: ChangePasswordView.self))] - Error: \n\(error)")
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
