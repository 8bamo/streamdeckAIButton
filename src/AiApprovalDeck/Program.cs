using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Windows.Forms;

namespace AiApprovalDeck;

internal static class Program
{
    private static readonly Dictionary<string, string> Defaults = new()
    {
        ["com.yusuf.aiapproval.yesonce"] = "1{ENTER}",
        ["com.yusuf.aiapproval.always"] = "2{ENTER}",
        ["com.yusuf.aiapproval.no"] = "3{ENTER}",
        ["com.yusuf.aiapproval.custom"] = "{ENTER}",
        ["com.yusuf.aiapproval.newchat"] = "^n",
        ["com.yusuf.aiapproval.modelmenu"] = "^+m"
    };

    [STAThread]
    private static async Task Main(string[] args)
    {
        var options = ParseArgs(args);
        if (!options.TryGetValue("-port", out var port) ||
            !options.TryGetValue("-pluginUUID", out var pluginUuid) ||
            !options.TryGetValue("-registerEvent", out var registerEvent))
        {
            return;
        }

        using var socket = new ClientWebSocket();
        await socket.ConnectAsync(new Uri($"ws://127.0.0.1:{port}"), CancellationToken.None);
        await SendJson(socket, new { @event = registerEvent, uuid = pluginUuid });

        var buffer = new byte[64 * 1024];
        while (socket.State == WebSocketState.Open)
        {
            var message = await ReceiveMessage(socket, buffer);
            if (message is null)
            {
                break;
            }

            HandleMessage(message);
        }
    }

    private static Dictionary<string, string> ParseArgs(string[] args)
    {
        var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        for (var i = 0; i < args.Length - 1; i += 2)
        {
            result[args[i]] = args[i + 1];
        }

        return result;
    }

    private static async Task SendJson(ClientWebSocket socket, object payload)
    {
        var json = JsonSerializer.Serialize(payload);
        var bytes = Encoding.UTF8.GetBytes(json);
        await socket.SendAsync(bytes, WebSocketMessageType.Text, true, CancellationToken.None);
    }

    private static async Task<string?> ReceiveMessage(ClientWebSocket socket, byte[] buffer)
    {
        using var stream = new MemoryStream();
        WebSocketReceiveResult result;
        do
        {
            result = await socket.ReceiveAsync(buffer, CancellationToken.None);
            if (result.MessageType == WebSocketMessageType.Close)
            {
                return null;
            }

            stream.Write(buffer, 0, result.Count);
        }
        while (!result.EndOfMessage);

        return Encoding.UTF8.GetString(stream.ToArray());
    }

    private static void HandleMessage(string message)
    {
        using var doc = JsonDocument.Parse(message);
        var root = doc.RootElement;

        if (!root.TryGetProperty("event", out var eventName) ||
            eventName.GetString() != "keyDown" ||
            !root.TryGetProperty("action", out var actionElement))
        {
            return;
        }

        var action = actionElement.GetString();
        if (string.IsNullOrWhiteSpace(action))
        {
            return;
        }

        var sequence = GetConfiguredSequence(root) ?? GetDefaultSequence(action);
        if (string.IsNullOrWhiteSpace(sequence))
        {
            return;
        }

        Thread.Sleep(80);
        SendKeys.SendWait(sequence);
    }

    private static string? GetConfiguredSequence(JsonElement root)
    {
        if (!root.TryGetProperty("payload", out var payload) ||
            !payload.TryGetProperty("settings", out var settings) ||
            !settings.TryGetProperty("sequence", out var sequenceElement))
        {
            return null;
        }

        var sequence = sequenceElement.GetString();
        return string.IsNullOrWhiteSpace(sequence) ? null : sequence;
    }

    private static string GetDefaultSequence(string action)
    {
        return Defaults.TryGetValue(action, out var sequence) ? sequence : "{ENTER}";
    }
}
