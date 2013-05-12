require 'java'
require 'jar/JNativeHook.jar'

import java.awt.Color
import java.awt.event.ActionListener
import java.awt.event.InputEvent
import java.awt.event.WindowListener
import java.awt.Robot

import java.io.ByteArrayInputStream

import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.JScrollPane
import javax.swing.JTextArea

import javax.imageio.ImageIO

import org.jnativehook.GlobalScreen
import org.jnativehook.keyboard.NativeKeyListener
import org.jnativehook.NativeHookException

# https://github.com/jruby/jruby/wiki/Persistence
Color.__persistent__ = true
GlobalScreen.__persistent__ = true
JScrollPane.__persistent__ = true
JTextArea.__persistent__ = true

module Shortcut
  class Window < JFrame
    include ActionListener
    include NativeKeyListener
    include WindowListener

    def create_button(text, action, options = {})
      options = {enabled: true}.merge(options)
      JButton.new(text).tap do |btn|
        btn.setActionCommand(action)
        btn.addActionListener(self)
        btn.setEnabled(options[:enabled])
      end
    end

    def robot
      @robot ||= Robot.new
    end

    def click(x, y)
      robot.mouseMove(x, y)
      robot.mousePress(InputEvent::BUTTON1_MASK)
      robot.mouseRelease(InputEvent::BUTTON1_MASK)
    end

    def feedback_text_area(start_text = '')
      @feedback_text_area ||= JTextArea.new.tap do |text_area|
        text_area.setEditable(false)
        text_area.setText(start_text)
        text_area.setBackground(Color::WHITE)
        text_area.setForeground(Color::BLACK)
      end
    end

    def feedback_scroll_panel(text_area, dimension)
      JScrollPane.new(text_area).tap do |scroll_panel|
        scroll_panel.setPreferredSize(dimension)
      end
    end

    def display_info(text)
      feedback_text_area.append("\n#{text}")
      feedback_text_area.setCaretPosition(feedback_text_area.getLineStartOffset(feedback_text_area.getLineCount() - 1))
    end

    def load_image(path)
      buffer_array = ByteArrayInputStream.new(File.read(path).to_java_bytes)
      image_input_stream = ImageIO.createImageInputStream(buffer_array)
      ImageIO.read(image_input_stream)
    end

    def operative_system
      java.lang.System.getProperty("os.name").downcase
    end

    def run
      setTitle(respond_to?(:default_title) ? default_title : 'Shortcut App')

      always_on_top if respond_to?(:always_on_top)
      GlobalScreen.getInstance.addNativeKeyListener(self)
      addWindowListener(self)
      setVisible true
    end

    class << self
      def title(text)
        send :define_method, :default_title do
          text
        end
      end

      def always_on_top(bool_value)
        send :define_method, :always_on_top do
          setAlwaysOnTop(bool_value)
        end
      end

      def key_pressed(code, action = nil, &block)
        send :define_method, "key_#{code}_pressed".to_sym do
          if action
            method_name = "action_#{action}_handler".to_sym
            raise UndefinedActionError.new("undefined action `#{action}'") unless respond_to?(method_name)
            self.send(method_name)
          else
            self.instance_eval(&block)
          end
        end
      end

      def action(name, &block)
        send :define_method, "action_#{name}_handler".to_sym do
          self.instance_eval(&block)
        end
      end
    end

    [:windowClosing, :windowIconified,
      :windowDeiconified, :windowActivated, :windowDeactivated].each do |name|
      define_method(name) { |e| }
    end

    def windowOpened(e)
      requestFocusInWindow
      GlobalScreen.registerNativeHook
    rescue NativeHookException => e
      display_info(e.toString)
    end

    def windowClosed(e)
      GlobalScreen.unregisterNativeHook
      java.lang.System.runFinalization
      java.lang.System.exit(0)
    end

    [:nativeKeyReleased, :nativeKeyTyped].each do |name|
      define_method(name) { |e| }
    end

    def nativeKeyPressed(event)
      method_name = "key_#{event.getKeyCode}_pressed".to_sym
      send(method_name) if respond_to?(method_name)
    end

    def actionPerformed(event)
      method_name = "action_#{event.getActionCommand}_handler".to_sym
      send(method_name) if respond_to?(method_name)
    end
  end
end
