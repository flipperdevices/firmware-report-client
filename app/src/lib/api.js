const server_url = import.meta.env.FW_BACKEND_URL;

export default async function api_get(api) {
    const res = await fetch("https://" + server_url + "/" + api, {
        method: "GET",
    });

    const json = await res.json();
    return json;
}
