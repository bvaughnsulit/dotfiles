export const NotificationPlugin = async ({ $, directory }) => {
  return {
    event: async ({ event }) => {
      if (event.type.includes('asked')) {
        await $`osascript -e 'display notification "${event.type} ${String(directory)}" with title "opencode"'`;
      }
    }
  }
}
