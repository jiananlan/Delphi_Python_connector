import win32pipe
import win32file
import time

process_data = lambda data: data + str(time.time())


def server():
    pipe_name = r'\\.\pipe\alj'

    while True:
        pipe = win32pipe.CreateNamedPipe(pipe_name,
                                         win32pipe.PIPE_ACCESS_DUPLEX,
                                         win32pipe.PIPE_TYPE_MESSAGE | win32pipe.PIPE_READMODE_MESSAGE | win32pipe.PIPE_WAIT,
                                         1, 65536, 65536, 0, None)
        try:
            win32pipe.ConnectNamedPipe(pipe, None)

            hr, data = win32file.ReadFile(pipe, 64 * 1024)
            data = data.decode('utf-8').strip()
            result = process_data(data)

            win32file.WriteFile(pipe, result.encode('utf-8'))
        except Exception as e:
            print(f"Error: {e}")
        finally:
            win32pipe.DisconnectNamedPipe(pipe)


if __name__ == '__main__':
    server()
