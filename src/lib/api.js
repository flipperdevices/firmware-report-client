let server = "http://127.0.0.1:5000/";

export default async function api_get(api) {
    const res = await fetch(server + api, {
        method: "GET",
    });

    const json = await res.json();
    return json;
}
