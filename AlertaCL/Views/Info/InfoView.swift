import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphericBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        infoCard(
                            title: "Qué es AlertaCL",
                            body: "App de monitoreo sísmico para Chile inspirada en sistemas de alerta temprana. Muestra sismos recientes, mapa interactivo y demos de notificación. No sustituye SENAPRED / CSN / mensajes oficiales del Estado."
                        )

                        infoCard(
                            title: "Fuentes de datos",
                            body: "Catálogo USGS FDSN (GeoJSON) filtrado al bounding box de Chile. El Centro Sismológico Nacional (CSN) publica datos oficiales; esta build usa USGS por disponibilidad abierta y latencia estable para prototipos."
                        )

                        infoCard(
                            title: "Niveles",
                            body: """
                            • Informativo < 4.5
                            • Vigilancia 4.5–5.4
                            • Alerta 5.5–6.4
                            • Crítico ≥ 6.5
                            """
                        )

                        infoCard(
                            title: "Liquid Glass (iOS 26)",
                            body: "La UI usa glassEffect, GlassEffectContainer e interactive() del design system Liquid Glass. Requiere iOS 26+."
                        )

                        infoCard(
                            title: "Sideload / IPA",
                            body: "El IPA de GitHub Releases viene sin firma de distribución. Instálalo con Sideloadly (o AltStore / TrollStore según dispositivo) usando tu Apple ID. Las notificaciones Critical de Apple no funcionan sin entitlement aprobado."
                        )

                        infoCard(
                            title: "Qué hacer en un sismo",
                            body: "Agáchate, cúbrete y sujétate. Aléjate de ventanas y objetos que puedan caer. Si estás en costa y el sismo es fuerte o prolongado, evacúa a zona alta por posible tsunami. Sigue canales oficiales SENAPRED."
                        )

                        Link(destination: URL(string: "https://www.csn.uchile.cl")!) {
                            Label("Centro Sismológico Nacional", systemImage: "link")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .glassEffect(.regular.tint(.cyan.opacity(0.25)).interactive(), in: .capsule)

                        Link(destination: URL(string: "https://www.senapred.gob.cl")!) {
                            Label("SENAPRED", systemImage: "link")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .glassEffect(.regular.tint(.orange.opacity(0.25)).interactive(), in: .capsule)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Información")
        }
    }

    private func infoCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }
}
