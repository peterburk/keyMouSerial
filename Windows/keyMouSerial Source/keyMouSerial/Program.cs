/*
 * keyMouSerial
 * Record keystrokes and mouse movement, and send them over serial
 * Peter Burkimsher 2015-06-25
 * peterburk@gmail.com
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.IO;
using System.IO.Ports;
using System.Drawing;

namespace keyMouSerial
{
    // Summary:
    //     Specifies key codes and modifiers.
    [ComVisible(true)]
    [Flags]
    
    // Key codes
    public enum Keys
    {
        // Summary:
        //     The bitmask to extract modifiers from a key value.
        Modifiers = -65536,
        //
        // Summary:
        //     No key pressed.
        None = 0,
        //
        // Summary:
        //     The left mouse button.
        LButton = 1,
        //
        // Summary:
        //     The right mouse button.
        RButton = 2,
        //
        // Summary:
        //     The CANCEL key.
        Cancel = 3,
        //
        // Summary:
        //     The middle mouse button (three-button mouse).
        MButton = 4,
        //
        // Summary:
        //     The first x mouse button (five-button mouse).
        XButton1 = 5,
        //
        // Summary:
        //     The second x mouse button (five-button mouse).
        XButton2 = 6,
        //
        // Summary:
        //     The BACKSPACE key.
        Back = 8,
        //
        // Summary:
        //     The TAB key.
        Tab = 9,
        //
        // Summary:
        //     The LINEFEED key.
        LineFeed = 10,
        //
        // Summary:
        //     The CLEAR key.
        Clear = 12,
        //
        // Summary:
        //     The ENTER key.
        Enter = 13,
        //
        // Summary:
        //     The RETURN key.
        Return = 13,
        //
        // Summary:
        //     The SHIFT key.
        ShiftKey = 16,
        //
        // Summary:
        //     The CTRL key.
        ControlKey = 17,
        //
        // Summary:
        //     The ALT key.
        Menu = 18,
        //
        // Summary:
        //     The PAUSE key.
        Pause = 19,
        //
        // Summary:
        //     The CAPS LOCK key.
        CapsLock = 20,
        //
        // Summary:
        //     The CAPS LOCK key.
        Capital = 20,
        //
        // Summary:
        //     The IME Kana mode key.
        KanaMode = 21,
        //
        // Summary:
        //     The IME Hanguel mode key. (maintained for compatibility; use HangulMode)
        HanguelMode = 21,
        //
        // Summary:
        //     The IME Hangul mode key.
        HangulMode = 21,
        //
        // Summary:
        //     The IME Junja mode key.
        JunjaMode = 23,
        //
        // Summary:
        //     The IME final mode key.
        FinalMode = 24,
        //
        // Summary:
        //     The IME Kanji mode key.
        KanjiMode = 25,
        //
        // Summary:
        //     The IME Hanja mode key.
        HanjaMode = 25,
        //
        // Summary:
        //     The ESC key.
        Escape = 27,
        //
        // Summary:
        //     The IME convert key.
        IMEConvert = 28,
        //
        // Summary:
        //     The IME nonconvert key.
        IMENonconvert = 29,
        //
        // Summary:
        //     The IME accept key. Obsolete, use System.Windows.Forms.Keys.IMEAccept instead.
        IMEAceept = 30,
        //
        // Summary:
        //     The IME accept key, replaces System.Windows.Forms.Keys.IMEAceept.
        IMEAccept = 30,
        //
        // Summary:
        //     The IME mode change key.
        IMEModeChange = 31,
        //
        // Summary:
        //     The SPACEBAR key.
        Space = 32,
        //
        // Summary:
        //     The PAGE UP key.
        Prior = 33,
        //
        // Summary:
        //     The PAGE UP key.
        PageUp = 33,
        //
        // Summary:
        //     The PAGE DOWN key.
        Next = 34,
        //
        // Summary:
        //     The PAGE DOWN key.
        PageDown = 34,
        //
        // Summary:
        //     The END key.
        End = 35,
        //
        // Summary:
        //     The HOME key.
        Home = 36,
        //
        // Summary:
        //     The LEFT ARROW key.
        Left = 37,
        //
        // Summary:
        //     The UP ARROW key.
        Up = 38,
        //
        // Summary:
        //     The RIGHT ARROW key.
        Right = 39,
        //
        // Summary:
        //     The DOWN ARROW key.
        Down = 40,
        //
        // Summary:
        //     The SELECT key.
        Select = 41,
        //
        // Summary:
        //     The PRINT key.
        Print = 42,
        //
        // Summary:
        //     The EXECUTE key.
        Execute = 43,
        //
        // Summary:
        //     The PRINT SCREEN key.
        PrintScreen = 44,
        //
        // Summary:
        //     The PRINT SCREEN key.
        Snapshot = 44,
        //
        // Summary:
        //     The INS key.
        Insert = 45,
        //
        // Summary:
        //     The DEL key.
        Delete = 46,
        //
        // Summary:
        //     The HELP key.
        Help = 47,
        //
        // Summary:
        //     The 0 key.
        D0 = 48,
        //
        // Summary:
        //     The 1 key.
        D1 = 49,
        //
        // Summary:
        //     The 2 key.
        D2 = 50,
        //
        // Summary:
        //     The 3 key.
        D3 = 51,
        //
        // Summary:
        //     The 4 key.
        D4 = 52,
        //
        // Summary:
        //     The 5 key.
        D5 = 53,
        //
        // Summary:
        //     The 6 key.
        D6 = 54,
        //
        // Summary:
        //     The 7 key.
        D7 = 55,
        //
        // Summary:
        //     The 8 key.
        D8 = 56,
        //
        // Summary:
        //     The 9 key.
        D9 = 57,
        //
        // Summary:
        //     The A key.
        A = 65,
        //
        // Summary:
        //     The B key.
        B = 66,
        //
        // Summary:
        //     The C key.
        C = 67,
        //
        // Summary:
        //     The D key.
        D = 68,
        //
        // Summary:
        //     The E key.
        E = 69,
        //
        // Summary:
        //     The F key.
        F = 70,
        //
        // Summary:
        //     The G key.
        G = 71,
        //
        // Summary:
        //     The H key.
        H = 72,
        //
        // Summary:
        //     The I key.
        I = 73,
        //
        // Summary:
        //     The J key.
        J = 74,
        //
        // Summary:
        //     The K key.
        K = 75,
        //
        // Summary:
        //     The L key.
        L = 76,
        //
        // Summary:
        //     The M key.
        M = 77,
        //
        // Summary:
        //     The N key.
        N = 78,
        //
        // Summary:
        //     The O key.
        O = 79,
        //
        // Summary:
        //     The P key.
        P = 80,
        //
        // Summary:
        //     The Q key.
        Q = 81,
        //
        // Summary:
        //     The R key.
        R = 82,
        //
        // Summary:
        //     The S key.
        S = 83,
        //
        // Summary:
        //     The T key.
        T = 84,
        //
        // Summary:
        //     The U key.
        U = 85,
        //
        // Summary:
        //     The V key.
        V = 86,
        //
        // Summary:
        //     The W key.
        W = 87,
        //
        // Summary:
        //     The X key.
        X = 88,
        //
        // Summary:
        //     The Y key.
        Y = 89,
        //
        // Summary:
        //     The Z key.
        Z = 90,
        //
        // Summary:
        //     The left Windows logo key (Microsoft Natural Keyboard).
        LWin = 91,
        //
        // Summary:
        //     The right Windows logo key (Microsoft Natural Keyboard).
        RWin = 92,
        //
        // Summary:
        //     The application key (Microsoft Natural Keyboard).
        Apps = 93,
        //
        // Summary:
        //     The computer sleep key.
        Sleep = 95,
        //
        // Summary:
        //     The 0 key on the numeric keypad.
        NumPad0 = 96,
        //
        // Summary:
        //     The 1 key on the numeric keypad.
        NumPad1 = 97,
        //
        // Summary:
        //     The 2 key on the numeric keypad.
        NumPad2 = 98,
        //
        // Summary:
        //     The 3 key on the numeric keypad.
        NumPad3 = 99,
        //
        // Summary:
        //     The 4 key on the numeric keypad.
        NumPad4 = 100,
        //
        // Summary:
        //     The 5 key on the numeric keypad.
        NumPad5 = 101,
        //
        // Summary:
        //     The 6 key on the numeric keypad.
        NumPad6 = 102,
        //
        // Summary:
        //     The 7 key on the numeric keypad.
        NumPad7 = 103,
        //
        // Summary:
        //     The 8 key on the numeric keypad.
        NumPad8 = 104,
        //
        // Summary:
        //     The 9 key on the numeric keypad.
        NumPad9 = 105,
        //
        // Summary:
        //     The multiply key.
        Multiply = 106,
        //
        // Summary:
        //     The add key.
        Add = 107,
        //
        // Summary:
        //     The separator key.
        Separator = 108,
        //
        // Summary:
        //     The subtract key.
        Subtract = 109,
        //
        // Summary:
        //     The decimal key.
        Decimal = 110,
        //
        // Summary:
        //     The divide key.
        Divide = 111,
        //
        // Summary:
        //     The F1 key.
        F1 = 112,
        //
        // Summary:
        //     The F2 key.
        F2 = 113,
        //
        // Summary:
        //     The F3 key.
        F3 = 114,
        //
        // Summary:
        //     The F4 key.
        F4 = 115,
        //
        // Summary:
        //     The F5 key.
        F5 = 116,
        //
        // Summary:
        //     The F6 key.
        F6 = 117,
        //
        // Summary:
        //     The F7 key.
        F7 = 118,
        //
        // Summary:
        //     The F8 key.
        F8 = 119,
        //
        // Summary:
        //     The F9 key.
        F9 = 120,
        //
        // Summary:
        //     The F10 key.
        F10 = 121,
        //
        // Summary:
        //     The F11 key.
        F11 = 122,
        //
        // Summary:
        //     The F12 key.
        F12 = 123,
        //
        // Summary:
        //     The F13 key.
        F13 = 124,
        //
        // Summary:
        //     The F14 key.
        F14 = 125,
        //
        // Summary:
        //     The F15 key.
        F15 = 126,
        //
        // Summary:
        //     The F16 key.
        F16 = 127,
        //
        // Summary:
        //     The F17 key.
        F17 = 128,
        //
        // Summary:
        //     The F18 key.
        F18 = 129,
        //
        // Summary:
        //     The F19 key.
        F19 = 130,
        //
        // Summary:
        //     The F20 key.
        F20 = 131,
        //
        // Summary:
        //     The F21 key.
        F21 = 132,
        //
        // Summary:
        //     The F22 key.
        F22 = 133,
        //
        // Summary:
        //     The F23 key.
        F23 = 134,
        //
        // Summary:
        //     The F24 key.
        F24 = 135,
        //
        // Summary:
        //     The NUM LOCK key.
        NumLock = 144,
        //
        // Summary:
        //     The SCROLL LOCK key.
        Scroll = 145,
        //
        // Summary:
        //     The left SHIFT key.
        LShiftKey = 160,
        //
        // Summary:
        //     The right SHIFT key.
        RShiftKey = 161,
        //
        // Summary:
        //     The left CTRL key.
        LControlKey = 162,
        //
        // Summary:
        //     The right CTRL key.
        RControlKey = 163,
        //
        // Summary:
        //     The left ALT key.
        LMenu = 164,
        //
        // Summary:
        //     The right ALT key.
        RMenu = 165,
        //
        // Summary:
        //     The browser back key (Windows 2000 or later).
        BrowserBack = 166,
        //
        // Summary:
        //     The browser forward key (Windows 2000 or later).
        BrowserForward = 167,
        //
        // Summary:
        //     The browser refresh key (Windows 2000 or later).
        BrowserRefresh = 168,
        //
        // Summary:
        //     The browser stop key (Windows 2000 or later).
        BrowserStop = 169,
        //
        // Summary:
        //     The browser search key (Windows 2000 or later).
        BrowserSearch = 170,
        //
        // Summary:
        //     The browser favorites key (Windows 2000 or later).
        BrowserFavorites = 171,
        //
        // Summary:
        //     The browser home key (Windows 2000 or later).
        BrowserHome = 172,
        //
        // Summary:
        //     The volume mute key (Windows 2000 or later).
        VolumeMute = 173,
        //
        // Summary:
        //     The volume down key (Windows 2000 or later).
        VolumeDown = 174,
        //
        // Summary:
        //     The volume up key (Windows 2000 or later).
        VolumeUp = 175,
        //
        // Summary:
        //     The media next track key (Windows 2000 or later).
        MediaNextTrack = 176,
        //
        // Summary:
        //     The media previous track key (Windows 2000 or later).
        MediaPreviousTrack = 177,
        //
        // Summary:
        //     The media Stop key (Windows 2000 or later).
        MediaStop = 178,
        //
        // Summary:
        //     The media play pause key (Windows 2000 or later).
        MediaPlayPause = 179,
        //
        // Summary:
        //     The launch mail key (Windows 2000 or later).
        LaunchMail = 180,
        //
        // Summary:
        //     The select media key (Windows 2000 or later).
        SelectMedia = 181,
        //
        // Summary:
        //     The start application one key (Windows 2000 or later).
        LaunchApplication1 = 182,
        //
        // Summary:
        //     The start application two key (Windows 2000 or later).
        LaunchApplication2 = 183,
        //
        // Summary:
        //     The OEM 1 key.
        Oem1 = 186,
        //
        // Summary:
        //     The OEM Semicolon key on a US standard keyboard (Windows 2000 or later).
        OemSemicolon = 186,
        //
        // Summary:
        //     The OEM plus key on any country/region keyboard (Windows 2000 or later).
        Oemplus = 187,
        //
        // Summary:
        //     The OEM comma key on any country/region keyboard (Windows 2000 or later).
        Oemcomma = 188,
        //
        // Summary:
        //     The OEM minus key on any country/region keyboard (Windows 2000 or later).
        OemMinus = 189,
        //
        // Summary:
        //     The OEM period key on any country/region keyboard (Windows 2000 or later).
        OemPeriod = 190,
        //
        // Summary:
        //     The OEM question mark key on a US standard keyboard (Windows 2000 or later).
        OemQuestion = 191,
        //
        // Summary:
        //     The OEM 2 key.
        Oem2 = 191,
        //
        // Summary:
        //     The OEM tilde key on a US standard keyboard (Windows 2000 or later).
        Oemtilde = 192,
        //
        // Summary:
        //     The OEM 3 key.
        Oem3 = 192,
        //
        // Summary:
        //     The OEM 4 key.
        Oem4 = 219,
        //
        // Summary:
        //     The OEM open bracket key on a US standard keyboard (Windows 2000 or later).
        OemOpenBrackets = 219,
        //
        // Summary:
        //     The OEM pipe key on a US standard keyboard (Windows 2000 or later).
        OemPipe = 220,
        //
        // Summary:
        //     The OEM 5 key.
        Oem5 = 220,
        //
        // Summary:
        //     The OEM 6 key.
        Oem6 = 221,
        //
        // Summary:
        //     The OEM close bracket key on a US standard keyboard (Windows 2000 or later).
        OemCloseBrackets = 221,
        //
        // Summary:
        //     The OEM 7 key.
        Oem7 = 222,
        //
        // Summary:
        //     The OEM singled/double quote key on a US standard keyboard (Windows 2000
        //     or later).
        OemQuotes = 222,
        //
        // Summary:
        //     The OEM 8 key.
        Oem8 = 223,
        //
        // Summary:
        //     The OEM 102 key.
        Oem102 = 226,
        //
        // Summary:
        //     The OEM angle bracket or backslash key on the RT 102 key keyboard (Windows
        //     2000 or later).
        OemBackslash = 226,
        //
        // Summary:
        //     The PROCESS KEY key.
        ProcessKey = 229,
        //
        // Summary:
        //     Used to pass Unicode characters as if they were keystrokes. The Packet key
        //     value is the low word of a 32-bit virtual-key value used for non-keyboard
        //     input methods.
        Packet = 231,
        //
        // Summary:
        //     The ATTN key.
        Attn = 246,
        //
        // Summary:
        //     The CRSEL key.
        Crsel = 247,
        //
        // Summary:
        //     The EXSEL key.
        Exsel = 248,
        //
        // Summary:
        //     The ERASE EOF key.
        EraseEof = 249,
        //
        // Summary:
        //     The PLAY key.
        Play = 250,
        //
        // Summary:
        //     The ZOOM key.
        Zoom = 251,
        //
        // Summary:
        //     A constant reserved for future use.
        NoName = 252,
        //
        // Summary:
        //     The PA1 key.
        Pa1 = 253,
        //
        // Summary:
        //     The CLEAR key.
        OemClear = 254,
        //
        // Summary:
        //     The bitmask to extract a key code from a key value.
        KeyCode = 65535,
        //
        // Summary:
        //     The SHIFT modifier key.
        Shift = 65536,
        //
        // Summary:
        //     The CTRL modifier key.
        Control = 131072,
        //
        // Summary:
        //     The ALT modifier key.
        Alt = 262144,
    }

    // MouseMessageFilter: Handle mouse events
    class MouseMessageFilter : IMessageFilter
    {
        // MouseMove: Capture mouse movement events, but not clicks
        public static event MouseEventHandler MouseMove = delegate { };
        const int WM_MOUSEMOVE = 0x0200;

        /*
         * PreFilterMessage: When the mosue moves, this captures the new position in x,y coordinates. 
         * @param Message m: Message to tell if the mouse moved
         * @return bool: Always false
         */
        public bool PreFilterMessage(ref Message m)
        {
            // If the mouse moved
            if (m.Msg == WM_MOUSEMOVE)
            {
                // Capture the mouse position
                System.Drawing.Point mousePosition = Control.MousePosition;

                // Run the MouseMove function to send the motion vector over serial
                MouseMove(null, new MouseEventArgs(
                    MouseButtons.None, 0, mousePosition.X, mousePosition.Y, 0));
            } // end if the mouse moved
            return false;
        } // end PreFilterMessage

    } // end class MouseMessageFilter


    /*
     * MouseHook: Handle mouse clicks
     */
    public class MouseHook
    {
        // Events: Mouse left click and right click delegates
        public static event EventHandler MouseAction = delegate { };
        public static event EventHandler MouseClicked = delegate { };
        public static event EventHandler MouseRightClicked = delegate { };

        // Start: Hook into the mouse movement
        public static void Start()
        {
            _hookID = SetHook(_proc);
        } // end Start()

        // stop(): Unhook from the mouse movement
        public static void stop()
        {
            UnhookWindowsHookEx(_hookID);
        } // end stop()

        // Low level mouse hook handlers
        private static LowLevelMouseProc _proc = HookCallback;
        private static IntPtr _hookID = IntPtr.Zero;

        /* 
         * SetHook: attach a mouse movement listener to the current process
         * @param LowLevelMouseProc proc: The mouse listener
         * @return IntPtr: The hook
         */
        private static IntPtr SetHook(LowLevelMouseProc proc)
        {
            // Attach to the current process
            using (Process curProcess = Process.GetCurrentProcess())
            using (ProcessModule curModule = curProcess.MainModule)
            {
                return SetWindowsHookEx(WH_MOUSE_LL, proc,
                  GetModuleHandle(curModule.ModuleName), 0);
            } // end using curProcess
        } // end SetHook

        // LowLevelMouseProc: A mouse movement listener below the application level. 
        private delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);

        /*
         * HookCallback: Handle mouse events when they happen
         * @param int nCode: Must be positive
         *        IntPtr wParam: The mouse button that was clicked
         *        IntPtr lParam: Not used
         * @return IntPtr: Next hook
         */
        private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
        {
            // Convert the hook to a structure
            MSLLHOOKSTRUCT hookStruct = (MSLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(MSLLHOOKSTRUCT));

            // If the nCode is positive and the button clicked is left, then run MouseClicked. 
            if (nCode >= 0 && MouseMessages.WM_LBUTTONDOWN == (MouseMessages)wParam)
            {
                MouseClicked(null, new EventArgs());
            } else {
                // If the nCode is positive and the button clicked is right, then run MouseRightClicked. 
                if (nCode >= 0 && MouseMessages.WM_RBUTTONDOWN == (MouseMessages)wParam)
                {
                    MouseRightClicked(null, new EventArgs());
                }
                else
                {
                    // Otherwise another mouse activitiy occurred
                    MouseAction(null, new EventArgs());
                } // end if right click
            } // end if left click
            
            return CallNextHookEx(_hookID, nCode, wParam, lParam);
        } // end HookCallback
        
        // Mouse, not keyboard
        private const int WH_MOUSE_LL = 14;

        // Mouse messages: left click down + up, right click down + up, mouse movement, mouse wheel
        private enum MouseMessages
        {
            WM_LBUTTONDOWN = 0x0201,
            WM_LBUTTONUP = 0x0202,
            WM_MOUSEMOVE = 0x0200,
            WM_MOUSEWHEEL = 0x020A,
            WM_RBUTTONDOWN = 0x0204,
            WM_RBUTTONUP = 0x0205
        } // end enum MouseMessages

        [StructLayout(LayoutKind.Sequential)]
        // The point from which we calculate the movement
        public struct POINT
        {
            public int x;
            public int y;
        } // end struct POINT

        [StructLayout(LayoutKind.Sequential)]
        // Hook
        private struct MSLLHOOKSTRUCT
        {
            public POINT pt;
            public uint mouseData;
            public uint flags;
            public uint time;
            public IntPtr dwExtraInfo;
        } // end hook

        // Bind to the mouse events user32 DLL
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook,
          LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode,
          IntPtr wParam, IntPtr lParam);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);


    } // end class MouseHook



    // Program: Where the actual action happens
    class Program
    {
        // Keyboard hook
        private const int WH_KEYBOARD_LL = 13;
        private const int WM_KEYDOWN = 0x0100;
        private static LowLevelKeyboardProc _proc = HookCallback;
        private static IntPtr _hookID = IntPtr.Zero;

        // This is where you can change your serial port settings
        private static SerialPort port = new SerialPort("COM3", 9600, Parity.None, 8, StopBits.One);
        //private static SerialPort port = new SerialPort("COM5", 9600, Parity.None, 8, StopBits.One);

        // Previous x,y mouse coordinates
        private int lastXValue = 0;
        private int lastYValue = 0;

        // Main: Run the app
        static void Main(string[] args)
        {
            Program thisProgram = new Program();
            thisProgram.run(args);
        } // end Main

        // Run: Set up the serial port and keyboard + mouse event handlers
        public void run (String[] args)
        {
            // Make a console window to capture inputs
            var handle = GetConsoleWindow();

            // Hide
            //ShowWindow(handle, SW_HIDE);

            // Open the serial port
            port.Open();

            // Watch for mouse events
            MouseHook.Start();
            MouseHook.MouseAction += new EventHandler(mouseMovedResponse);
            MouseHook.MouseClicked += new EventHandler(mouseClickedResponse);
            MouseHook.MouseRightClicked += new EventHandler(mouseRightClickedResponse);

            // Watch for keyboard events
            _hookID = SetHook(_proc);

            // Run the app
            Application.Run();
            
            // Close cleanly
            UnhookWindowsHookEx(_hookID);
        } // end function run

        // mouseClickedResponse: Handle a left click
        private void mouseClickedResponse(object sender, EventArgs g)
        {
            // Write "b" (button) character to the serial port
            port.Write(@"b");

            // Write "l" (left click) character to the serial port
            port.Write(@"l");
        } // end mouseClickedResponse

        // mouseRightClickedResponse: Handle a right click
        private void mouseRightClickedResponse(object sender, EventArgs g)
        {
            // Write "b" (button) character to the serial port
            port.Write(@"b");

            // Write "r" (right click) character to the serial port
            port.Write(@"r");
        } // end mouseRightClickedResponse

        // mouseMovedResponse: Handle mouse movement
        private void mouseMovedResponse(object sender, EventArgs g)
        {
            // Find the current mouse location
            int xValue = System.Windows.Forms.Cursor.Position.X;
            int yValue = System.Windows.Forms.Cursor.Position.Y;

            // Calculate characters to send based on an offset
            int characterOffset = 64;

            //xValue = MouseHook.POINT.x;

            // Compare the current mouse position to the last position
            int xMoved = lastXValue - xValue + characterOffset;
            int yMoved = lastYValue - yValue + characterOffset;

            // Convert the integer change to a character
            char xChar = (char)xMoved;
            char yChar = (char)yMoved;

            // Convert the character to a string
            String xString = xChar.ToString();
            String yString = yChar.ToString();

            // Combine a string and log it to the console for reference
            String thisLine = @"x"+xMoved+@" "+xString+@" y"+yMoved+@" "+yString;
            Console.WriteLine(thisLine);

            // Write the x coordinate to the serial port
            port.Write(@"x");
            String keystroke = xString;
            port.Write(keystroke);

            // Write the y coordinate to the serial port
            port.Write(@"y");
            keystroke = yString;
            port.Write(keystroke);

            // Write the ? terminating character to the serial port
            port.Write(@"?");

            // Update the last x,y value variables
            lastXValue = xValue;
            lastYValue = yValue;
        } // mouseMovedResponse

        // LowLevelKeyboardProc: Keyboard event delegate
        private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr IParam);

        /*
         * HookCallback: Handle keyboard events
         * @param int nCode: Greater than zero
         *        IntPtr wParam: Is this a keystroke event?
         *        IntPtr IParam: The integer value of the keystroke
         */
        private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr IParam)
        {
            // If a key was pressed
            if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN)
            {
                // Find the key code of the pressed key
                int vkCode = Marshal.ReadInt32(IParam);
                Console.WriteLine((Keys)vkCode);

                // Look up the string value of the key code
                String keystroke = @""+((Keys)vkCode);

                // Substitute some key codes: space and return
                if (vkCode == 32)
                { keystroke = " "; }

                if (vkCode == 13)
                { keystroke = "\n"; }

                // Write "k" (key) to the serial port
                port.Write(@"k");

                // Write the keystroke to the serial port
                port.Write(keystroke);

                // Also save the keystrokes to a log file
                StreamWriter sw = new StreamWriter(Application.StartupPath + @"\log.txt", true);
                sw.Write((Keys)vkCode);
                sw.Close();
            } // end if a key was pressed
            return CallNextHookEx(_hookID, nCode, wParam, IParam);
        } // end function HookCallback

        // SetHook: Attach the keyboard logging hook to this process
        private static IntPtr SetHook(LowLevelKeyboardProc proc)
        {
            using (Process curProcess = Process.GetCurrentProcess())
            using (ProcessModule curModule = curProcess.MainModule)
            {
                return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
            } // end curModule
        } // end function SetHook


        // Bind to the keyboard events user32 DLL
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc Ipfn, IntPtr hMod, uint dwThreadId);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr IParam);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string IpModuleName);

        [DllImport("kernel32.dll")]
        static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        const int SW_HIDE = 0;


    } // end class Program
} // end namespace keyMouSerial
