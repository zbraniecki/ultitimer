using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class NumberPicker extends Ui.Picker {
  function initialize(range, def, text) {
    var title = new Ui.Text({
      :text=>"              " + text,
      :font=>Gfx.FONT_SMALL,
      :justification=>Gfx.TEXT_JUSTIFY_LEFT});
    var factories = new [1];
    factories[0] = new NumberFactory(range[0], range[1], 1);

    var defaults = new [1];

    defaults[0] = def;

    Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
  }
}

class TimePicker extends Ui.Picker {
  function initialize(range, def, text) {
    var title = new Ui.Text({
      :text=>"              " + text,
      :font=>Gfx.FONT_SMALL,
      :justification=>Gfx.TEXT_JUSTIFY_LEFT});
    var factories = new [2];
    factories[0] = new NumberFactory(0, 9, 1);
    factories[1] = new NumberFactory(0, 59, 1);

    var defaults = new [2];

    var seconds = def % 60;
    var minutes = (def - seconds) / 60;

    defaults[0] = minutes;
    defaults[1] = seconds;

    Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
  }
}

class DistancePicker extends Ui.Picker {
  function initialize(text) {
    var distance = App.getApp().getProperty("distance");

    var title = new Ui.Text({
      :text=>"              " + text,
      :font=>Gfx.FONT_SMALL,
      :justification=>Gfx.TEXT_JUSTIFY_LEFT});


    var factories = new [1];
    factories[0] = new DistanceFactory();

    var defaults = new [1];

    defaults[0] = arrayIndexOf(defaultDistances, distance);

    Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
  }
}

class TargetPickerDelegate extends Ui.PickerDelegate {
  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(values) {
    App.getApp().setProperty("target", values[0]);
    var distance = App.getApp().getProperty("distance");
    App.getApp().setProperty("manualTargetPM", values[0] * 1000 / distance);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }
}

class RestPickerDelegate extends Ui.PickerDelegate {
  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(values) {
    var value = values[0] * 60 + values[1];
    App.getApp().setProperty("rest", value);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }
}

class RepsPickerDelegate extends Ui.PickerDelegate {
  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(values) {
    App.getApp().setProperty("reps", values[0]);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }
}

class DistancePickerDelegate extends Ui.PickerDelegate {
  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(values) {
    var manualTargetPM = App.getApp().getProperty("manualTargetPM");
    
    var distance = values[0];

    App.getApp().setProperty("distance", distance);

    var time = (manualTargetPM * distance) / 1000;

    App.getApp().setProperty("target", time);
    Ui.requestUpdate();
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }
}

class NumberFactory extends Ui.PickerFactory {
  hidden var mStart;
  hidden var mStop;
  hidden var mIncrement;
  hidden var mFormatString;
  hidden var mFont;

  function getIndex(value) {
    var index = (value / mIncrement) - mStart;
    return index;
  }

  function initialize(start, stop, increment, options) {
    mStart = start;
    mStop = stop;
    mIncrement = increment;

    if(options != null) {
        mFormatString = options.get(:format);
        mFont = options.get(:font);
    }

    if(mFont == null) {
        mFont = Gfx.FONT_NUMBER_HOT;
    }

    if(mFormatString == null) {
        mFormatString = "%d";
    }
  }

  function getDrawable(index, selected) {
    return new Ui.Text( { :text=>getValue(index).format(mFormatString), :color=>Gfx.COLOR_WHITE, :font=> mFont, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_CENTER } );
  }

  function getValue(index) {
    return mStart + (index * mIncrement);
  }

  function getSize() {
    return ( mStop - mStart ) / mIncrement + 1;
  }
}

class DistanceFactory extends Ui.PickerFactory {
  function getSize() {
    return defaultDistances.size();
  }

  function getValue(index) {
    return defaultDistances[index];
  }

  function getDrawable(index, selected) {
    return new Ui.Text( { :text=>getValue(index).format("%d"), :color=>Gfx.COLOR_WHITE, :font=> Gfx.FONT_NUMBER_HOT, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_CENTER } );
  }
}
