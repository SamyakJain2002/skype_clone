import 'package:flutter/cupertino.dart';
import 'package:skype/enum/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState _viewState = ViewState.idle;
  ViewState get getViewState => _viewState;

  void setToLoading() {
    _viewState = ViewState.loading;
    notifyListeners();
  }

  void setToIdle() {
    _viewState = ViewState.idle;
    notifyListeners();
  }
}
