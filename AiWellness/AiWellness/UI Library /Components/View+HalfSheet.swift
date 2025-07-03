import SwiftUI

extension View {
    func halfSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.background(
            HalfSheetHelper(isPresented: isPresented, sheetContent: content)
        )
    }
}

private struct HalfSheetHelper<SheetContent: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let sheetVC = UIHostingController(rootView: sheetContent())
            sheetVC.modalPresentationStyle = .pageSheet
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            uiViewController.present(sheetVC, animated: true) {
                isPresented = false
            }
        }
    }
}
