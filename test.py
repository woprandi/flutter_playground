# pip install websockets
import asyncio
import websockets

async def echo(websocket):
    i = 0
    while True:
        print(f"sending {i}")
        await websocket.send(str(i))
        i += 1
        await asyncio.sleep(1)

async def main():
    async with websockets.serve(echo, "localhost", 8765):
        print("ws://localhost:8765")
        await asyncio.Future()  # run forever

asyncio.run(main())
