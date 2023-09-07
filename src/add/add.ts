type MyEvent = {
  name: string;
};

export async function handler(event: MyEvent) {
  return { msg: `Hello ${event.name} World` };
}