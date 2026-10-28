# Mermaid Diagram Templates

Use diagrams for meaningful component relationships or data flow, not as decoration. Adapt these templates to the actual project; omit nonexistent databases, caches, workers, packages, and deployment stages. Simple libraries, utilities, and documentation-only repos often do not need a diagram.

## API / Web App

```mermaid
graph LR
    Client[Client] --> API[API Server]
    API --> DB[(Database)]
    API --> Cache[(Cache)]
    API --> Queue[Message Queue]
    Queue --> Worker[Worker]
```

## Monorepo

```mermaid
graph TD
    Root[Monorepo Root] --> Core[packages/core]
    Root --> CLI[packages/cli]
    Root --> Web[packages/web]
    CLI --> Core
    Web --> Core
```

## Content Pipeline

```mermaid
graph LR
    Source[Content Source] --> Transform[Build / Transform]
    Transform --> Output[Generated Output]
    Output --> Publish[Publish]
```

## CLI Tool

```mermaid
graph LR
    Input[User Input] --> Parser[Argument Parser]
    Parser --> Command[Command Handler]
    Command --> Output[Output]
    Command --> FS[File System]
```

## Plugin Architecture

```mermaid
graph TD
    Core[Core Engine] --> PluginA[Plugin A]
    Core --> PluginB[Plugin B]
    Core --> PluginC[Plugin C]
    PluginA --> API[Shared API]
    PluginB --> API
    PluginC --> API
```

Check that the Mermaid code fences are balanced, labels are readable, and arrows accurately represent dependencies or data flow; explain arrow meaning if it is ambiguous.
