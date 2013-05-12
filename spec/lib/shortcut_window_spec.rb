require "spec_helper"
require "shortcut/errors"
require "shortcut/window"
require "ostruct"

import java.awt.Dimension
import java.awt.event.KeyEvent

# https://github.com/jruby/jruby/wiki/Persistence
Dimension.__persistent__ = true

# Title property
class TitleClass < Shortcut::Window; title 'Test title'; end

# AlwaysOnTop property
class AlwaysOnTopTrueClass < Shortcut::Window; always_on_top true; end
class AlwaysOnTopFalseClass < Shortcut::Window; always_on_top false; end
class AlwaysOnTopNoneClass < Shortcut::Window; end

# Size property
class SizedClass < Shortcut::Window; size 100, 200; end
class DefaultSizedClass < Shortcut::Window; end

# NativeKeyListener
class ListenerExampleClass < Shortcut::Window
  attr_accessor :called_actions, :key_pressed_events

  action 'some_action' do
    self.called_actions ||= []
    self.called_actions << 'some_action'
  end

  action 'action_q_key' do
    self.called_actions ||= []
    self.called_actions << 'action_q_key'
  end

  key_pressed KeyEvent::VK_Q, :action_q_key
  key_pressed KeyEvent::VK_W, :undefined_action

  key_pressed KeyEvent::VK_ESCAPE do
    self.key_pressed_events ||= []
    self.key_pressed_events << KeyEvent::VK_ESCAPE
  end
end

describe Shortcut::Window do
  let(:window) { Shortcut::Window.new }

  it 'inherits from JFrame' do
    window.should be_a(JFrame)
  end

  it 'includes NativeKeyListener' do
    window.should be_a(NativeKeyListener)
  end

  it 'includes WindowListener' do
    window.should be_a(WindowListener)
  end

  describe :create_button do
    let(:jbutton) { double('jbutton').as_null_object }

    it 'returns an instance of JButton' do
      window.create_button('text', 'action').should be_a(JButton)
    end

    it 'creates a button with text' do
      JButton.should_receive(:new).with('text').and_return(jbutton)
      window.create_button('text', anything())
    end

    it 'creates a button with action' do
      JButton.should_receive(:new).and_return(jbutton)
      jbutton.should_receive(:setActionCommand).with('action')
      window.create_button(anything(), 'action')
    end

    it 'returns the created button' do
      JButton.should_receive(:new).and_return(jbutton)
      window.create_button(anything(), anything()).should eq(jbutton)
    end

    it 'enables the button by default' do
      JButton.should_receive(:new).and_return(jbutton)
      jbutton.should_receive(:setEnabled).with(true)
      window.create_button(anything(), anything())
    end

    it 'accepts an enabled option to disable the button' do
      JButton.should_receive(:new).and_return(jbutton)
      jbutton.should_receive(:setEnabled).with(false)
      window.create_button(anything(), anything(), {enabled: false})
    end

    it 'adds self as action listener' do
      JButton.should_receive(:new).and_return(jbutton)
      jbutton.should_receive(:addActionListener).with(window)
      window.create_button(anything(), anything())
    end
  end

  describe :robot do
    let(:robot) { double('robot') }

    it 'returns an instance of Robot' do
      window.robot.should be_a(Robot)
    end

    it 'creates and returns a Robot' do
      Robot.should_receive(:new).and_return(robot)
      window.robot.should eq(robot)
    end

    it 'caches result' do
      Robot.should_receive(:new).once.and_return(robot)
      window.robot.should eq(robot)
      window.robot.should eq(robot)
    end
  end

  describe :click do
    let(:robot) { double('robot') }

    before(:each) do
      window.stub(:robot) { robot }
    end

    it 'moves mouse to correct position, presses and releases left mouse button, all in the correct order' do
      robot.should_receive(:mouseMove).with(1, 2).ordered
      robot.should_receive(:mousePress).with(InputEvent::BUTTON1_MASK).ordered
      robot.should_receive(:mouseRelease).with(InputEvent::BUTTON1_MASK).ordered
      window.click(1, 2)
    end
  end

  describe :feedback_text_area do
    let(:text_area) { double('text area').as_null_object }

    it 'returns an instance of JTextArea' do
      window.feedback_text_area.should be_a(JTextArea)
    end

    it 'sets the text' do
      JTextArea.should_receive(:new).and_return(text_area)
      text_area.should_receive(:setText).with('Text')
      window.feedback_text_area('Text')
    end

    it 'disables the returned area' do
      JTextArea.should_receive(:new).and_return(text_area)
      text_area.should_receive(:setEditable).with(false)
      window.feedback_text_area
    end

    it 'sets the background white' do
      JTextArea.should_receive(:new).and_return(text_area)
      text_area.should_receive(:setBackground).with(Color::WHITE)
      window.feedback_text_area
    end

    it 'sets the foreground black' do
      JTextArea.should_receive(:new).and_return(text_area)
      text_area.should_receive(:setForeground).with(Color::BLACK)
      window.feedback_text_area
    end

    it 'caches result' do
      JTextArea.should_receive(:new).once.and_return(text_area)
      window.feedback_text_area.should eq(text_area)
      window.feedback_text_area.should eq(text_area)
    end
  end

  describe :feedback_scroll_panel do
    let(:text_area) { JTextArea.new }
    let(:dimension) { Dimension.new }

    it 'returns an instance of JScrollPane' do
      window.feedback_scroll_panel(text_area, dimension).should be_a(JScrollPane)
    end

    it 'creates the scroll panel with the text_area argument' do
      scroll_panel = JScrollPane.new
      JScrollPane.should_receive(:new).with(text_area).and_return(scroll_panel)
      window.feedback_scroll_panel(text_area, dimension)
    end

    it 'sets preferred size' do
      scroll_panel = JScrollPane.new
      JScrollPane.should_receive(:new).with(text_area).and_return(scroll_panel)
      scroll_panel.should_receive(:setPreferredSize).with(dimension)
      window.feedback_scroll_panel(text_area, dimension)
    end
  end

  describe :display_info do
    it 'append message to feedback text area' do
      window.display_info('A')
      window.display_info('B')
      window.feedback_text_area.getText.should eq("\nA\nB")
    end

    it 'scrolls down' do
      window.display_info('A')
      window.feedback_text_area.getCaretPosition.should eq(1)
      window.display_info('B')
      window.feedback_text_area.getCaretPosition.should eq(3)
      window.display_info('C')
      window.feedback_text_area.getCaretPosition.should eq(5)
    end
  end

  describe :load_image do
    let(:reader) { double('reader').as_null_object }
    let(:java_bytes_reader) { double('java bytes reader') }
    let(:input_stream) { double('input stream') }
    let(:image_input_stream) { double('image input stream') }
    let(:image) { double('image') }

    it 'loads an image' do
      File.should_receive(:read).with('path').and_return(reader)
      reader.should_receive(:to_java_bytes).and_return(java_bytes_reader)
      ByteArrayInputStream.should_receive(:new).with(java_bytes_reader).and_return(input_stream)
      ImageIO.should_receive(:createImageInputStream).with(input_stream).and_return(image_input_stream)
      ImageIO.should_receive(:read).with(image_input_stream).and_return(image)

      window.load_image('path').should eq(image)
    end
  end

  describe :operative_system do
    it 'returns lowercased os.name property' do
      java.lang.System.should_receive(:getProperty).with("os.name").and_return('Linux')
      window.operative_system.should eq('linux')
    end
  end

  describe :run do
    before(:each) do
      Shortcut::Window.any_instance.stub(:setVisible)
    end

    describe :title do
      it 'sets the JFrame title' do
        title = TitleClass.new
        title.run
        title.getTitle.should eq('Test title')
      end

      it 'sets a JFrame default title of "Shortcut App"' do
        window.run
        window.getTitle.should eq('Shortcut App')
      end
    end

    describe 'always on top property' do
      it 'sets property to true' do
        on_top_true = AlwaysOnTopTrueClass.new
        on_top_true.should_receive(:setAlwaysOnTop).with(true)
        on_top_true.run
      end

      it 'sets property to false' do
        on_top_false = AlwaysOnTopFalseClass.new
        on_top_false.should_receive(:setAlwaysOnTop).with(false)
        on_top_false.run
      end

      it 'does not set property' do
        on_top_none = AlwaysOnTopNoneClass.new
        on_top_none.should_not_receive(:setAlwaysOnTop)
        on_top_none.run
      end
    end

    describe 'size property' do
      it 'sets property' do
        sized_window = SizedClass.new
        sized_window.should_receive(:setSize).with(100, 200)
        sized_window.run
      end

      it 'does not set property and defaults to 440 by 250' do
        default_sized_window = DefaultSizedClass.new
        default_sized_window.should_receive(:setSize).with(440, 250)
        default_sized_window.run
      end
    end

    it 'adds a window listener' do
      window.should_receive(:addWindowListener).with(window)
      window.run
    end

    it 'adds a native key listener' do
      GlobalScreen.getInstance.should_receive(:addNativeKeyListener).with(window)
      window.run
    end

    it 'sets visibility to true' do
      window.should_receive(:setVisible).with(true)
      window.run
    end
  end

  describe 'window listeners' do
    [:windowOpened, :windowClosed, :windowClosing, :windowIconified,
      :windowDeiconified, :windowActivated, :windowDeactivated].each do |event|
      it { window.should respond_to(event).with(1).argument }
    end

    describe :windowOpened do
      it 'requests focus in window' do
        window.should_receive(:requestFocusInWindow)
        window.windowOpened(anything())
      end

      it 'registers native hook' do
        GlobalScreen.should_receive(:registerNativeHook)
        window.windowOpened(anything())
      end

      it 'handles exception when registering native hook' do
        GlobalScreen.should_receive(:registerNativeHook).and_raise(NativeHookException.new('error message!'))
        window.should_receive(:display_info).with('org.jnativehook.NativeHookException: error message!')
        window.windowOpened(anything())
      end
    end

    describe :windowClosed do
      before(:each) do
        java.lang.System.stub(:exit)
      end

      it 'unregisters native hook' do
        GlobalScreen.should_receive(:unregisterNativeHook)
        window.windowClosed(anything())
      end

      it 'runs system finalization' do
        java.lang.System.should_receive(:runFinalization)
        window.windowClosed(anything())
      end

      it 'exit system with value 0' do
        java.lang.System.should_receive(:exit).with(0)
        window.windowClosed(anything())
      end
    end
  end

  describe 'native key listeners' do
    [:nativeKeyReleased, :nativeKeyTyped, :nativeKeyPressed].each do |event|
      it { window.should respond_to(event).with(1).argument }
    end

    describe :nativeKeyPressed do
      it 'executes block from key_pressed function' do
        key_event = OpenStruct.new(getKeyCode: KeyEvent::VK_ESCAPE)

        listener_example = ListenerExampleClass.new
        listener_example.nativeKeyPressed(key_event)

        listener_example.key_pressed_events.should eq([KeyEvent::VK_ESCAPE])
      end

      it 'does not raise exception when handler not defined' do
        key_event = OpenStruct.new(getKeyCode: KeyEvent::VK_0)

        listener_example = ListenerExampleClass.new
        expect { listener_example.nativeKeyPressed(key_event) }.not_to raise_exception
      end

      it 'works with an action' do
        key_event = OpenStruct.new(getKeyCode: KeyEvent::VK_Q)

        listener_example = ListenerExampleClass.new
        listener_example.nativeKeyPressed(key_event)

        listener_example.called_actions.should eq(['action_q_key'])
      end

      it 'works with an action' do
        key_event = OpenStruct.new(getKeyCode: KeyEvent::VK_W)

        listener_example = ListenerExampleClass.new
        expect { listener_example.nativeKeyPressed(key_event) }.to raise_exception(Shortcut::UndefinedActionError, "undefined action `undefined_action'")
      end
    end
  end

  describe :actionPerformed do
    it { window.should respond_to(:actionPerformed).with(1).argument }

    it 'executes block from action function' do
      action_event = OpenStruct.new(getActionCommand: 'some_action')

      listener_example = ListenerExampleClass.new
      listener_example.actionPerformed(action_event)

      listener_example.called_actions.should eq(['some_action'])
    end

    it 'does not raise exception when handler not defined' do
      action_event = OpenStruct.new(getActionCommand: 'undefined_action')

      listener_example = ListenerExampleClass.new
      expect { listener_example.actionPerformed(action_event) }.not_to raise_exception
    end
  end
end
