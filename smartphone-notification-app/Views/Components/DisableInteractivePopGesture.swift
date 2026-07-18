import SwiftUI

/// このビューが表示されている間だけ、NavigationStackのスワイプで戻る操作を無効化する。
/// NavigationStackは画面端に限らずどこから始まったパンでも戻る遷移を認識することがあり、
/// `interactivePopGestureRecognizer`だけでは抑えられないため、
/// navigationController.view上の(自分以外の)UIPanGestureRecognizerをすべて無効化する。
struct DisableInteractivePopGesture: UIViewControllerRepresentable {
    final class Controller: UIViewController, UIGestureRecognizerDelegate {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            disablePopGesture()
            // NavigationStack側がジェスチャーを後から追加/再有効化するケースに備えて少し遅らせて再適用
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.disablePopGesture()
            }
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            disablePopGesture()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            restorePopGesture()
        }

        func disablePopGesture() {
            guard let navController = navigationController else { return }
            navController.interactivePopGestureRecognizer?.isEnabled = false
            navController.interactivePopGestureRecognizer?.delegate = self

            for recognizer in navController.view.gestureRecognizers ?? [] {
                guard recognizer is UIPanGestureRecognizer,
                      recognizer !== navController.interactivePopGestureRecognizer else { continue }
                recognizer.isEnabled = false
            }
        }

        private func restorePopGesture() {
            guard let navController = navigationController else { return }
            navController.interactivePopGestureRecognizer?.isEnabled = true
            if navController.interactivePopGestureRecognizer?.delegate === self {
                navController.interactivePopGestureRecognizer?.delegate = nil
            }

            for recognizer in navController.view.gestureRecognizers ?? [] {
                guard recognizer is UIPanGestureRecognizer,
                      recognizer !== navController.interactivePopGestureRecognizer else { continue }
                recognizer.isEnabled = true
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            false
        }
    }

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.disablePopGesture()
    }
}
